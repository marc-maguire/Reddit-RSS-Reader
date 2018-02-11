//
//  RSSDataFetcher.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import Foundation
import Alamofire

class RSSDataFetcher {
	
	func refreshRSSFeed(completion: @escaping (()->([FeedItem]))) {
		
		// Fetch Request
		Alamofire.request("https://www.reddit.com/hot/.rss", method: .get).validate(statusCode: 200..<300).responseData { response in
			if (response.result.error == nil) {
				debugPrint("HTTP Response Body: \(response.data)")
			}
			else {
				debugPrint("HTTP Request failed: \(response.result.error)")
			}
		}
	}
}
