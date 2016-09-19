//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	func initialize(withPhoto photo: Photo) {
		
		self.activityIndicator.isHidden = true
		
		if let data = photo.imageData as? Data, let image = UIImage(data: data) {
			self.imageView.image = image
		} else {
			self.imageView.image = UIImage(named: "placeholder")
		}
		
	}
	
	func startsIndicator() {
		self.activityIndicator.isHidden = false
		self.imageView.alpha = 0.5
		self.activityIndicator.startAnimating()
	}
	
	func stopIndicator() {
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true
		self.imageView.alpha = 1.0
	}
    
}
