//
//  ContentViewController.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit
import WebKit

class ContentViewController: UIViewController {

	@IBOutlet weak var webView: WKWebView!
	private var contentURL: String? {
		didSet {
			guard let urlString = self.contentURL, let url = URL(string: urlString) else { return }
			let urlRequest = URLRequest(url: url)
			webView.load(urlRequest)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
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
