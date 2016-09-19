//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by David Moeller on 18/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
	
	var title: String?
	var coordinate: CLLocationCoordinate2D
	var pin: Pin
	var photoDetailsState: FlickrPhotoDetailsState {
		didSet {
			switch self.photoDetailsState {
			case .photos(photos: let photoDetailsList):
				if let page = photoDetailsList.first?.page {
					self.page = page
				}
				if let maxPage = photoDetailsList.first?.maxPage {
					self.maxPage = maxPage
				}
				self.loadingPhotos = true
				downloadPhotos(forPin: self.pin, andPhotoDetailsList: photoDetailsList, withCompletionHandler: {
					self.loadingPhotos = false
				})
			default:
				return
			}
		}
	}
	var page = 1
	var maxPage = 1
	var loadingPhotos = false
	
	init(title: String?, pin: Pin) {
		self.title = title
		self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
		self.pin = pin
		self.photoDetailsState = .empty
	}
	
	func incrementPage() {
		page += 1
		if page > maxPage {
			page = maxPage
		}
	}
	
}

enum FlickrPhotoDetailsState {
	case empty
	case photos(photos: [FlickrPhotoDetails])
}
