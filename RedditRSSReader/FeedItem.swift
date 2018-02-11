//
//  FeedItem.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import Foundation
import UIKit

class FeedItem {
	private let title: String
	private let dateUpdated: Date
	private let category: String
	private let thumbnail: UIImage?
	private let thumbnailURLString: String
	private let contentURLString: String
	
	init(title: String, dateUpdated: Date, category: String, thumbnailURLString: String, contentURLString: String) {
		self.title = title
		self.dateUpdated = dateUpdated
		self.category = category
		self.thumbnail = nil
		self.thumbnailURLString = thumbnailURLString
		self.contentURLString = contentURLString
	}
}
