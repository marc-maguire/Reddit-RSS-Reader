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
	
	let title: String
	let dateUpdated: String
	let category: String
	let thumbnail: UIImage?
	let thumbnailURLString: String?
	let contentURLString: String
	
	init(title: String, dateUpdated: String, category: String, thumbnailURLString: String?, contentURLString: String) {
		self.title = title
		self.dateUpdated = dateUpdated
		self.category = category
		self.thumbnail = nil
		self.thumbnailURLString = thumbnailURLString
		self.contentURLString = contentURLString
	}
}
