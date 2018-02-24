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
	
	let id: String
	let title: String
	let dateUpdated: String
	let category: String
	var thumbnail: Data?
	let thumbnailURLString: String?
	let contentURLString: String
	var isPinned: Bool = false
	
	init(id: String, title: String, dateUpdated: String, category: String, thumbnail: Data? = nil, thumbnailURLString: String?, contentURLString: String, isPinned: Bool = false) {
		self.id = id
		self.title = title
		self.dateUpdated = dateUpdated
		self.category = category
		self.thumbnail = thumbnail
		self.thumbnailURLString = thumbnailURLString
		self.contentURLString = contentURLString
		self.isPinned = isPinned
	}
	convenience init(fromEntity feedItemEntity: FeedItemEntity) {
		self.init(id: feedItemEntity.id, title: feedItemEntity.title, dateUpdated: feedItemEntity.dateUpdated, category: feedItemEntity.category, thumbnail: feedItemEntity.thumbnail as Data?, thumbnailURLString: nil, contentURLString: feedItemEntity.contentURLString, isPinned: true)
	}
}
