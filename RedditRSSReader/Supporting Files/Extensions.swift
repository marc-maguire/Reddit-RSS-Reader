//
//  Extensions.swift
//  RedditRSSReader
//
//  Created by Marc Maguire on 2018-02-24.
//  Copyright © 2018 Marc Maguire. All rights reserved.
//

import UIKit

//MARK: - UIView Extensions

extension UIView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
}
