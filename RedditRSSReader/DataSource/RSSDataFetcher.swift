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
	
	private var parserDidFinishParsingEvent: (()->())? = nil
	private var parsedFeedItems: [FeedItem] = []
	private var currentElement: String? = nil
	
	//Values we will be parsing out:
	private var id: String = ""
	private var title: String = ""
	private var dateUpdated: String = ""
	private var category: String = ""
	private var content: String = ""
	
	enum DownloadSource: String {
		case reddit = "https://www.reddit.com/hot/.rss"
	}
	
	enum ParseTerms: String {
		case contentURL = "href="
		case thumbnailURL = "src="
	}
	
	enum Constants {
		static let id = "id"
		static let title = "title"
		static let dateUpdated = "updated"
		static let category = "category"
		static let content = "content"
		static let queue = "XMLParsingQueue"
		static let dateAt = " at "
	}
	
	func refreshRSSFeed(completion: @escaping (([FeedItem])->())) {
		
		//we need a queue so that our Alamofire request will return to the same queue that our xml parser will parse on and not the main thread
		let queue: DispatchQueue = DispatchQueue(label: Constants.queue, qos: .userInitiated, target: nil)
		queue.async {
			self.downloadRSSFeeds(fromSource: .reddit, queue: queue) { data, error in
				guard error == nil, let data = data else {
					completion([])
					return
				}
				let parser = XMLParser(data: data)
				parser.delegate = self
				self.parserDidFinishParsingEvent = { () in
					DispatchQueue.main.async {
						completion(self.parsedFeedItems)
					}
				}
				//the parser is synchronus, make sure you are on a background thread
				if !parser.parse() {
					print("parser failed during processing")
					completion([])
				}
			}
		}
	}
	
	func downloadRSSFeeds(fromSource: DownloadSource, queue: DispatchQueue, completion: @escaping (_ data: Data?, _ error: Error?) ->()) {
		// Fetch Request
		Alamofire.request(fromSource.rawValue, method: .get).validate(statusCode: 200..<300).responseData(queue: queue) { response in
			switch response.result {
			case .success:
				completion(response.data, response.error)
			case .failure:
				print("Reddit XML download failed: \(String(describing: response.result.error))")
				completion(nil, nil)
			}
		}
	}
	
	func resetParserVars() {
		self.title = ""
		self.dateUpdated = ""
		self.category = ""
		self.content = ""
	}
	
	func parseURL(_ URLType: ParseTerms, fromContent content: String) -> String? {
		let segments = content.components(separatedBy: " ")
		var parsedURL: String?
		
		for segment in segments {
			if segment.contains(URLType.rawValue) {
				parsedURL = segment.components(separatedBy: "=").last
				let parsedURL1 = parsedURL?.replacingOccurrences(of: "\\", with: "")
				let parsedURL2 = parsedURL1?.replacingOccurrences(of: "\"", with: "")
				parsedURL = parsedURL2?.replacingOccurrences(of: ">", with: "")
				
				break
			}
		}
		guard var unwrappedParsedURL = parsedURL else { return parsedURL }
		for char in unwrappedParsedURL {
			if char != "h" {
				unwrappedParsedURL.removeFirst()
			} else if char == "h" {
				parsedURL = unwrappedParsedURL
				break
			}
		}
		return parsedURL
	}
	
	func formatISO8601Date(dateString: String) -> String? {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		guard let date = dateFormatter.date(from: dateString) else { return nil }
		let stringComponents = dateFormatter.string(from: date).components(separatedBy: "T")
		guard let firstItem = stringComponents.first, let secondItem = stringComponents.last else { return nil }
		let formattedDateString = firstItem + Constants.dateAt + secondItem
		return formattedDateString
	}
	
	//MARK: - XML Parser Delegate
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		self.currentElement = elementName
		if elementName == Constants.category {
			guard let categoryValue = attributeDict.values.first else {return}
			self.category = categoryValue
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		//lets build
		if self.currentElement == Constants.title {
			self.title.append(string)
		} else if self.currentElement == Constants.dateUpdated {
			self.dateUpdated.append(string)
		} else if self.currentElement == Constants.content {
			self.content.append(string)
		} else if self.currentElement == Constants.id {
			self.id.append(string)
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == Constants.title {
			guard let dateUpdated = self.formatISO8601Date(dateString: self.dateUpdated), let contentURLString = self.parseURL(.contentURL, fromContent: self.content), self.id != "" else {
				self.resetParserVars()
				print("Received bad data or parsing logic failed, skipping creation of feed item")
				return
			}
			
			//we want to know if this is nil, we will use a default thumb if not
			let thumbURLString = self.parseURL(.thumbnailURL, fromContent: self.content)
			let newFeedItem = FeedItem(id: self.id, title: self.title, dateUpdated: dateUpdated, category: self.category, thumbnailURLString: thumbURLString, contentURLString: contentURLString)
			guard let thumbURL = thumbURLString, let url = URL(string: thumbURL), let data = try? Data(contentsOf: url) else {
				self.parsedFeedItems.append(newFeedItem)
				self.resetParserVars()
				return
			}
			newFeedItem.thumbnail = data
			self.parsedFeedItems.append(newFeedItem)
			self.resetParserVars()
		}
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		self.parserDidFinishParsingEvent?()
	}
	
	
}
