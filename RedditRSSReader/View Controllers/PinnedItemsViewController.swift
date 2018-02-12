//
//  PinnedItemsViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

class PinnedItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedItemCellDelegate {
	
	@IBOutlet weak private var tableView: UITableView!
	private var pinnedFeedItems: [FeedItem] = [] {
		didSet {
			self.pinnedFeedItems = self.pinnedFeedItems.sorted() { $0.dateUpdated > $1.dateUpdated }
			self.tableView.reloadData()
		}
	}
	
	private enum SegueConstants {
		static let contentViewController = "ContentViewControllerSegue"
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController, let pinnedItems = rSSTabBar.getFeedItems() else { return }
		self.pinnedFeedItems = pinnedItems
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
			feedCell.configureCell(thumbnailImage: "hello", title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: feedItem.isPinned, image: nil)
			return cell
		}
		let image = UIImage(data: data)
		feedCell.configureCell(thumbnailImage: "hello", title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: feedItem.isPinned, image: image)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = self.pinnedFeedItems[indexPath.row]
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.setSelectedContentURL(string: selectedItem.contentURLString)
		self.performSegue(withIdentifier: SegueConstants.contentViewController, sender: self)
	}
	
	//MARK: - FeedItemCellDelegate
	
	func feedItemCellButtonClicked(atIndexPath: IndexPath) {
		
		//save to coreData / move to next VC
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		self.pinnedFeedItems.remove(at: atIndexPath.row)
		rSSTabBar.removeFeedItem(atIndex: atIndexPath)
	}
}
