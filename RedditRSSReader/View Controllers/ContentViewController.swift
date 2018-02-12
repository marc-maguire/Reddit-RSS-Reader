//
//  ContentViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit
import WebKit

class ContentViewController: UIViewController, WKNavigationDelegate {

	@IBOutlet weak var webView: WKWebView!
	private var contentURL: String? {
		didSet {
			guard let urlString = self.contentURL, let url = URL(string: urlString) else {
				print("failed to make url from urlString: \(self.contentURL)")
				return }
			let urlRequest = URLRequest(url: url)
			self.webView.load(urlRequest)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.webView.navigationDelegate = self
		self.webView.allowsBackForwardNavigationGestures = true
		
//		"https://www.google.com"
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let tabController = self.tabBarController as? RSSTabBarController, let contentToLoad = tabController.getSelectedContentURL() else {
			self.navigationController?.dismiss(animated: false, completion: nil)
			return }
		print("content to load: \(contentToLoad)")
		self.contentURL = contentToLoad
	}

	func setContentURL(_ withString: String) {
		self.contentURL = withString
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
