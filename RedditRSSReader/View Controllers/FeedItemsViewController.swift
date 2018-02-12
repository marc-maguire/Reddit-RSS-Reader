//
//  FeedItemsViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

class FeedItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedItemCellDelegate {
	
	@IBOutlet weak private var tableView: UITableView!
	private var feedItems: [FeedItem] = []
	
	private enum SegueConstants {
		static let contentViewController = "ContentViewControllerSegue"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
		let downloader = RSSDataFetcher()
		downloader.refreshRSSFeed { feedItems in
			self.feedItems = feedItems
			self.tableView.reloadData()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController, let pinnedItems = rSSTabBar.getFeedItems(), !pinnedItems.isEmpty else {
			self.unpinAll()
			return
		}
		//could this be done better?
		for feedItem in self.feedItems {
			for pinnedItem in pinnedItems {
				if feedItem.contentURLString == pinnedItem.contentURLString {
					feedItem.isPinned = pinnedItem.isPinned
				}
			}
		}
	}
	
	private func unpinAll() {
		for item in self.feedItems {
			item.isPinned = false
		}
		self.tableView.reloadData()
	}
	
	private func syncUnpinning() {
		
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedItemTableViewCell.self), for: indexPath)
		guard let feedCell = cell as? FeedItemTableViewCell else { return cell }
		feedCell.delegate = self
		feedCell.indexPath = indexPath
		let feedItem = self.feedItems[indexPath.row]
		feedCell.configureCell(thumbnailImage: "hello", title: feedItem.title, dateUpdated: feedItem.dateUpdated, category: feedItem.category, isSelected: feedItem.isPinned)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = self.feedItems[indexPath.row]
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.setSelectedContentURL(string: selectedItem.contentURLString)
		self.performSegue(withIdentifier: SegueConstants.contentViewController, sender: self)
	}
	
	//MARK: - FeedItemCellDelegate
	
	func feedItemCellButtonClicked(atIndexPath: IndexPath) {
		let feedItem = self.feedItems[atIndexPath.row]
		feedItem.isPinned = true
		//save to coreData / move to next VC
		guard let rSSTabBar = self.tabBarController as? RSSTabBarController else { return }
		rSSTabBar.appendFeedItem(feedItem: feedItem)
	}
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		guard let destinationVC = segue.destination as? ContentViewController else { return }
//
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
//    }
}
