//
//  FlickrPhotoDetails.swift
//  Virtual Tourist
//
//  Created by David Moeller on 18/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation

struct FlickrPhotoDetails {
	
	let id: String
	let owner: String
	let secret: String
	let server: String
	let farm: String
	var page: Int?
	var maxPage: Int?
	
	var photoURL: String {
		return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
	}
	
}
