//
//  RSSTabBarController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

class RSSTabBarController: UITabBarController {
	
	private var feedItems: [FeedItem] = []
	private var selectedContentURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setFeedItems(feedItems: [FeedItem]) {
		self.feedItems = feedItems
	}
	
	func setSelectedContentURL(string: String) {
		self.selectedContentURL = string
	}
	
	func getSelectedContentURL() -> String? {
		return self.selectedContentURL
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
