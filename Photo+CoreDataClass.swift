//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Photo: NSManagedObject {
	
	convenience init(image: UIImage?, flickrUrl: String, loading: Bool, context: NSManagedObjectContext) {
		if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
			self.init(entity: ent, insertInto: context)
			if let image = image {
				self.imageData = UIImagePNGRepresentation(image) as NSData?
			}
			self.flickrUrl = flickrUrl
			self.loading = loading
		} else {
			fatalError("Unable to find Entity Name")
		}
	}

}
