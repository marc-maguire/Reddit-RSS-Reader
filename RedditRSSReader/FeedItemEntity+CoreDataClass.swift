//
//  FeedItemEntity+CoreDataClass.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-18.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//
//

import Foundation
import CoreData


public class FeedItemEntity: NSManagedObject {
	
	class func createOrDeleteEntity(fromItem feedItem: FeedItem) {
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.createFetchRequest()
		let predicate = NSPredicate(format: "id == %@", feedItem.id)
		fetchRequest.predicate = predicate
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			if searchResults.count == 0 {
				//create it
				let feedItemEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: FeedItemEntity.self), into: CoreDataController.getContext()) as! FeedItemEntity
				
				feedItemEntity.title = feedItem.title
				feedItemEntity.contentURLString = feedItem.contentURLString
				if let thumbnailData = feedItem.thumbnail {
					feedItemEntity.thumbnail = thumbnailData as NSData
				} else {
					feedItemEntity.thumbnail = nil
				}
				feedItemEntity.category = feedItem.category
				feedItemEntity.dateUpdated = feedItem.dateUpdated
				feedItemEntity.id = feedItem.id
			} else {				CoreDataController.getContext().delete(searchResults.first!)
			}
			CoreDataController.saveContext()
		} catch {
			print("Fetch failed due to error: \(error)")
		}
	}
	
	class func getAll() -> [FeedItemEntity] {
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.createFetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateUpdated", ascending: false)]
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			return searchResults
		} catch {
			print("Fetch failed due to error: \(error)")
			return []
		}
	}
	
	class func deleteEntity(withID ID: String) {
		let fetchRequest: NSFetchRequest<FeedItemEntity> = FeedItemEntity.createFetchRequest()
		let predicate = NSPredicate(format: "id == %@", ID)
		fetchRequest.predicate = predicate
		do {
			let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
			guard searchResults.count == 1 else { return }
			CoreDataController.getContext().delete(searchResults.first!)
			CoreDataController.saveContext()
		} catch {
			print("Fetch failed due to error: \(error)")
		}
	}

}
