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
	
	@IBAction func pinnedbuttonPressed(_ sender: UIButton) {
		//change button state to the opposite of what it was
		self.toggleButtonSelectedState(isSelected: self.pinnedButton.isSelected)
		self.delegate?.feedItemCellButtonClicked(atIndexPath: self.indexPath)
	}
	
	func toggleButtonSelectedState(isSelected: Bool) {
		self.pinnedButton.isSelected = !isSelected
	}
	
	var indexPath: IndexPath!
	
	var delegate: FeedItemCellDelegate?
	
	func configureCell(thumbnailImage: String, title: String, dateUpdated: String, category: String) {
//		self.thumbnailImageView.image = thumbnailImage
		self.feedTitleLabel.text = title
		self.dateUpdatedLabel.text = dateUpdated
		self.feedCategoryLabel.text = category
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
