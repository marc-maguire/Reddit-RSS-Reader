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

	@IBOutlet weak private var webView: WKWebView!
	
	private var currentlyLoadedURL: String?
	private var contentURL: String? {
		didSet {
			guard let urlString = self.contentURL, urlString != self.currentlyLoadedURL, let url = URL(string: urlString) else {
				print("failed to make url from urlString: \(String(describing: self.contentURL)), or URL was already loaded.")
				return }
			self.currentlyLoadedURL = urlString
			let urlRequest = URLRequest(url: url)
			self.webView.load(urlRequest)
		}
	}
	
	//MARK: - Lifecycle
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.webView.navigationDelegate = self
		self.webView.allowsBackForwardNavigationGestures = true
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

}
