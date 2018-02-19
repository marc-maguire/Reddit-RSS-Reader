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
	private var feedItems: [FeedItem] = []
	
	lazy private var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(FeedItemsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
		return refreshControl
	}()
	
	private enum Constants {
		static let contentViewControllerSegue = "ContentViewControllerSegue"
		static let feedItems = "Feed Items"
		static let feedItemEntityClassName = String(describing: FeedItemEntity.self)
	}
	
	//MARK: - App Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.addSubview(self.refreshControl)
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
		self.navigationItem.title = Constants.feedItems
		self.refreshFeed() {
			print("feed refreshed")
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.syncPinnedItems()
		self.tableView.reloadData()
	}
	
	//MARK: - Refresh / Pinning
	
	@objc func handleRefresh(refreshControl: UIRefreshControl) {
		self.refreshFeed {
			self.refreshControl.endRefreshing()
		}
	}
	
	private func refreshFeed(completion: @escaping ()->()) {
		let downloader = RSSDataFetcher()
		downloader.refreshRSSFeed { feedItems in
			self.feedItems = feedItems.sorted() { $0.dateUpdated > $1.dateUpdated }
			self.syncPinnedItems()
			self.tableView.reloadData()
			completion()
		}
	}
	
	private func unpinAll() {
		for item in self.feedItems {
			item.isPinned = false
		}
	}
	
	private func syncPinnedItems() {
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController, let pinnedItems = rSSTabBar.getFeedItems(), !pinnedItems.isEmpty else {
			self.unpinAll()
			return
		}
		//could this be done better?
		self.unpinAll()
		for feedItem in self.feedItems {
			for pinnedItem in pinnedItems {
				if feedItem.contentURLString == pinnedItem.contentURLString {
					feedItem.isPinned = true
				}
			}
		}
	}
	
	//MARK: - Table View Data Source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedItemTableViewCell.self), for: indexPath)
		guard let feedCell = cell as? FeedItemTableViewCell else { return cell }
		feedCell.delegate = self
		feedCell.indexPath = indexPath
		let feedItem = self.feedItems[indexPath.row]
		guard let data = feedItem.thumbnail else {
			feedCell.configureCell(title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: feedItem.isPinned, image: nil)
			return cell
		}
		let image = UIImage(data: data)
		feedCell.configureCell(title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: feedItem.isPinned, image: image)
		return cell
	}
	
	//MARK: - Table View Delegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = self.feedItems[indexPath.row]
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.setSelectedContentURL(string: selectedItem.contentURLString)
		self.performSegue(withIdentifier: Constants.contentViewControllerSegue, sender: self)
	}
	
	//MARK: - FeedItemCellDelegate
	
	func feedItemCellButtonClicked(atIndexPath: IndexPath) {
		let feedItem = self.feedItems[atIndexPath.row]
		//does it exist?
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.fetchRequest()
		let predicate = NSPredicate(format: "id == %@", feedItem.id)
		fetchRequest.predicate = predicate
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			if searchResults.count == 0 {
				//create it
				let feedItemEntity = NSEntityDescription.insertNewObject(forEntityName: Constants.feedItemEntityClassName, into: CoreDataController.getContext()) as! FeedItemEntity
				
				feedItemEntity.title = feedItem.title
				if let thumbnailData = feedItem.thumbnail {
					feedItemEntity.thumbnail = thumbnailData as NSData
				} else {
					feedItemEntity.thumbnail = nil
				}
				feedItemEntity.category = feedItem.category
				feedItemEntity.dateUpdated = feedItem.dateUpdated
				feedItemEntity.id = feedItem.id
			} else {
				//delete it
				CoreDataController.getContext().delete(searchResults.first!)
			}
			CoreDataController.saveContext()
		} catch {
			print("Fetch failed due to error: \(error)")
		}
	}
}
