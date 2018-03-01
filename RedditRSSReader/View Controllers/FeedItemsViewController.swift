//
//  FeedItemsViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit
import CoreData

class FeedItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedItemCellDelegate {
	
	@IBOutlet weak private var tableView: UITableView!
	
	@IBOutlet weak private var spinner: UIActivityIndicatorView!
	
	private var feedItems: [FeedItem] = [] {
		didSet {
			self.tableView.reloadData()
		}
	}
	private var feedLoaded = false
	
	
	lazy private var downloader: RSSDataFetcher = RSSDataFetcher()
	
	lazy private var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(FeedItemsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
		return refreshControl
	}()
	
	private enum Constants {
		static let contentViewControllerSegue = "ContentViewControllerSegue"
		static let feedItems = "Feed Items"
	}
	
	//MARK: - App Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTableView()
		self.navigationItem.title = Constants.feedItems
		self.spinner.startAnimating()
		self.refreshFeed() {
			self.feedLoaded = true
			self.spinner.stopAnimating()
			print("feed refreshed")
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if self.feedLoaded {
			self.syncPinnedItems()
		}
	}
	
	//MARK: - Setup
	
	private func setupTableView() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.addSubview(self.refreshControl)
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
	}
	
	//MARK: - Refresh / Pinning
	
	@objc func handleRefresh(refreshControl: UIRefreshControl) {
		self.refreshFeed {
			self.refreshControl.endRefreshing()
		}
	}
	
	private func refreshFeed(completion: @escaping ()->()) {
		self.downloader.refreshRSSFeed { feedItems in
			self.feedItems = feedItems
			self.syncPinnedItems()
			completion()
		}
	}
	
	private func unpinAll() {
		for item in self.feedItems {
			item.isPinned = false
		}
	}
	
	private func syncPinnedItems() {
		self.unpinAll()
		let searchResults = FeedItemEntity.getAll()
		guard searchResults.count != 0 else {
			self.sortFeedItemsDescending()
			return
		}
		for result in searchResults {
			if let match = self.feedItems.first(where: { $0.id == result.id }) {
				match.isPinned = true
			} else {
				let feedItem = FeedItem(fromEntity: result)
				self.feedItems.append(feedItem)
			}
		}
		self.sortFeedItemsDescending()
	}
	
	private func sortFeedItemsDescending() {
		self.feedItems = self.feedItems.sorted() { $0.dateUpdated > $1.dateUpdated }
	}
	
	//MARK: - Table View Data Source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedItemTableViewCell.self), for: indexPath)
		guard let feedCell = cell as? FeedItemTableViewCell else { return cell }
		feedCell.delegate = self
		let feedItem = self.feedItems[indexPath.row]
		guard let data = feedItem.thumbnail else {
			feedCell.configureCell(withFeedItem: feedItem)
			return cell
		}
		let image = UIImage(data: data)
		feedCell.configureCell(withFeedItem: feedItem, image: image)
		return cell
	}
	
	//MARK: - Table View Delegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = self.feedItems[indexPath.row]
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.setSelectedContentURL(string: selectedItem.contentURLString)
		self.performSegue(withIdentifier: Constants.contentViewControllerSegue, sender: self)
	}
	
	private var finishedLoadingInitialTableCells = false
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//		ref: https://stackoverflow.com/questions/33410482/table-view-cell-load-animation-one-after-another
		var lastInitialDisplayableCell = false
		
		//change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
		if self.feedItems.count > 0 && !self.finishedLoadingInitialTableCells {
			if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
				let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
				lastInitialDisplayableCell = true
			}
		}
		if !self.finishedLoadingInitialTableCells {
			if lastInitialDisplayableCell {
				self.finishedLoadingInitialTableCells = true
			}
			
			//animates the cell as it is being displayed for the first time
			cell.transform = CGAffineTransform(translationX: 0, y: 80/2)
			cell.alpha = 0
			
			UIView.animate(withDuration: 0.3, delay: 0.03*Double(indexPath.row), options: [.curveEaseInOut], animations: {
				cell.transform = CGAffineTransform(translationX: 0, y: 0)
				cell.alpha = 1
			}, completion: nil)
		}
		
	}
	
	//MARK: - FeedItemCellDelegate
	
	func feedItemCellButtonClicked(withContentURL URL: String) {
		if let feedItem = self.feedItems.first(where: { $0.contentURLString == URL }) {
		feedItem.isPinned = true
		FeedItemEntity.createOrDeleteEntity(fromItem: feedItem)
		}
	}
}
