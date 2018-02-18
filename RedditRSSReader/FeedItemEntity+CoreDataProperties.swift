//
//  FeedItemEntity+CoreDataProperties.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-18.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItemEntity> {
        return NSFetchRequest<FeedItemEntity>(entityName: "FeedItemEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var contentURLString: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var category: String?
    @NSManaged public var dateUpdated: String?
    @NSManaged public var id: String?

}
