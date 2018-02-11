//
//  RSSDataFetcher.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import Foundation
import Alamofire

class RSSDataFetcher: NSObject, XMLParserDelegate {
	
	enum DownloadSource: String {
		case reddit = "https://www.reddit.com/hot/.rss"
	}
	
	func refreshRSSFeed(completion: @escaping (([FeedItem])->())) {
		
		self.downloadRSSFeeds(fromSource: .reddit) { data, error in
			guard error == nil, let data = data else {
				completion([])
				return
			}
			let parser = XMLParser(data: data)
			parser.delegate = self
		}
		
	}
	
	func downloadRSSFeeds(fromSource: DownloadSource, completion: @escaping (_ data: Data?, _ error: Error?) ->()) {
		// Fetch Request
		Alamofire.request(fromSource.rawValue, method: .get).validate(statusCode: 200..<300).responseData { response in
			switch response.result {
			case .success:
				completion(response.data, response.error)
			case .failure:
				print("Reddit XML download failed: \(String(describing: response.result.error))")
				completion(nil, nil)
			}
		}
	}
	
	//MARK: - XML Parser Delegate
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		//lets start
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		//lets build
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		//keep it up
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		//notify the boss
	}
	
	
}
