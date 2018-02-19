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
	private var pinnedFeedItems: [FeedItem] = [] {
		didSet {
			self.pinnedFeedItems = self.pinnedFeedItems.sorted() { $0.dateUpdated > $1.dateUpdated }
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
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UINib(nibName: String(describing: FeedItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedItemTableViewCell.self))
		self.navigationItem.title = Constants.pinnedItems
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.pinnedFeedItems.removeAll()
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.fetchRequest()
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			guard searchResults.count != 0 else { return }
			
			for item in searchResults {
				let newFeedItem = FeedItem(id: item.id, title: item.title, dateUpdated: item.dateUpdated, category: item.category, thumbnail: item.thumbnail as Data?, thumbnailURLString: nil, contentURLString: item.contentURLString)
				self.pinnedFeedItems.append(newFeedItem)
			}
			self.tableView.reloadData()
		} catch {
			print("Fetch failed due to error: \(error)")
		}
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
		let image = UIImage(data: data)
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
	
	//MARK: - FeedItemCellDelegate
	
	func feedItemCellButtonClicked(atIndexPath: IndexPath) {
		
		//save to coreData / move to next VC
		let feedItem = self.pinnedFeedItems[atIndexPath.row]
		//does it exist?
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.fetchRequest()
		let predicate = NSPredicate(format: "id == %@", feedItem.id)
		fetchRequest.predicate = predicate
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			guard searchResults.count == 1 else { return }
			CoreDataController.getContext().delete(searchResults.first!)
			CoreDataController.saveContext()
		} catch {
			print("Fetch failed due to error: \(error)")
		}
		self.pinnedFeedItems.remove(at: atIndexPath.row)
	}
}
