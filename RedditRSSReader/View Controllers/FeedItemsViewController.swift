//
//  FeedItemsViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

class FeedItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak private var tableView: UITableView!
	private var feedItems: [FeedItem] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedItemTableViewCell.self), for: indexPath)
		return cell
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
