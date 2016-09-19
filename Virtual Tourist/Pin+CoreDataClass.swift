//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject {
	
	convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
		if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
			self.init(entity: ent, insertInto: context)
			self.latitude = Float(coordinate.latitude)
			self.longitude = Float(coordinate.longitude)
		} else {
			fatalError("Unable to find Entity Name")
		}
	}

}
