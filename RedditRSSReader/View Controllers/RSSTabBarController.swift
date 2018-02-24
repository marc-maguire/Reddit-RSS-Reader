//
//  RSSTabBarController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

class RSSTabBarController: UITabBarController {
	
	private var selectedContentURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setSelectedContentURL(string: String) {
		self.selectedContentURL = string
	}
	
	func getSelectedContentURL() -> String? {
		return self.selectedContentURL
	}

}
