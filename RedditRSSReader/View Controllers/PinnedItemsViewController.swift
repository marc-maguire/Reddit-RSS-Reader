//
//  PinnedItemsViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit
import CoreData

class PinnedItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedItemCellDelegate {
	
	@IBOutlet weak private var tableView: UITableView!
	private var pinnedFeedItems: [FeedItemEntity] = [] {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	private enum Constants {
		static let contentViewControllerSegue = "ContentViewControllerSegue"
		static let pinnedItems = "Pinned Items"
	}
	
	//MARK: - App Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTableView()
		self.navigationItem.title = Constants.pinnedItems
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.pinnedFeedItems = FeedItemEntity.getAll()
	}
	
	//MARK: - Setup
	
	private func setupTableView() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
	}
	
	//MARK: - Table View Data Source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.pinnedFeedItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedItemTableViewCell.self), for: indexPath)
		guard let feedCell = cell as? FeedItemTableViewCell else { return cell }
		feedCell.delegate = self
		feedCell.indexPath = indexPath
		let feedItem = self.pinnedFeedItems[indexPath.row]
		guard let data = feedItem.thumbnail else {
			feedCell.configureCell(title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: true, image: nil)
			return cell
		}
		let image = UIImage(data: data as Data)
		feedCell.configureCell(title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: true, image: image)
		return cell
	}
	
	//MARK: - Table View Delegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = self.pinnedFeedItems[indexPath.row]
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.setSelectedContentURL(string: selectedItem.contentURLString)
		self.performSegue(withIdentifier: Constants.contentViewControllerSegue, sender: self)
	}
	
	private var finishedLoadingInitialTableCells = false
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		//ref: https://stackoverflow.com/questions/33410482/table-view-cell-load-animation-one-after-another
		var lastInitialDisplayableCell = false
		
		//change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
		if self.pinnedFeedItems.count > 0 && !finishedLoadingInitialTableCells {
			if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
				let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
				lastInitialDisplayableCell = true
			}
		}
		if !finishedLoadingInitialTableCells {
			if lastInitialDisplayableCell {
				finishedLoadingInitialTableCells = true
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
	
	func feedItemCellButtonClicked(atIndexPath: IndexPath) {
		let feedItem = self.pinnedFeedItems[atIndexPath.row]
		FeedItemEntity.deleteEntity(withID: feedItem.id)
		self.pinnedFeedItems.remove(at: atIndexPath.row)
	}
}
