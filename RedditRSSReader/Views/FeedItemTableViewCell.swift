//
//  FeedItemTableViewCell.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-11.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

protocol FeedItemCellDelegate{
	func feedItemCellButtonClicked(atIndexPath: IndexPath)
}

class FeedItemTableViewCell: UITableViewCell {

	@IBOutlet weak private var thumbnailImageView: UIImageView!
	
	@IBOutlet weak private var feedTitleLabel: UILabel!
	
	@IBOutlet weak private var dateUpdatedLabel: UILabel!
	
	@IBOutlet weak private var feedCategoryLabel: UILabel!
	
	@IBOutlet weak private var pinnedButton: UIButton!
	
	@IBAction private func pinnedbuttonPressed(_ sender: UIButton) {
		//change button state to the opposite of what it was
		self.toggleButtonSelectedState(isSelected: self.pinnedButton.isSelected)
		self.delegate?.feedItemCellButtonClicked(atIndexPath: self.indexPath)
	}
	
	var indexPath: IndexPath!
	
	var delegate: FeedItemCellDelegate?
	
	private enum Constants {
		static let updatedOn = "Last updated on: "
	}
	
	private func toggleButtonSelectedState(isSelected: Bool) {
		self.pinnedButton.isSelected = !isSelected
	}
	
	func configureCell(title: String, dateUpdated: String, category: String, isSelected: Bool, image: UIImage?) {
		
		self.feedTitleLabel.text = title
		self.dateUpdatedLabel.text = Constants.updatedOn + dateUpdated
		self.feedCategoryLabel.text = category
		self.pinnedButton.isSelected = isSelected
		if let image = image {
			self.thumbnailImageView.image = image
		} else {
			self.thumbnailImageView.image = UIImage(named: "first")
		}
		
	}
    
}
