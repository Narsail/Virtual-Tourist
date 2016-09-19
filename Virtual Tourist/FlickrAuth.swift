//
//  FlickrAuth.swift
//  Virtual Tourist
//
//  Created by David Moeller on 18/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation

class FlickrAuth: BackendAuth {
	
	let key: String
	let secret: String
	
	init(key: String = "35161d3ad26b87a00dde0961eef68b3e", secret: String = "f9f5d0c65f097039") {
		self.key = key
		self.secret = secret
	}
	
	func headerParameters() -> [String : String] {
		return [
			"api_key": key,
		]
	}
	
}
