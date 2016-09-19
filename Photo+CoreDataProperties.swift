//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by David Moeller on 18/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var flickrUrl: String?
    @NSManaged public var loading: Bool
    @NSManaged public var pin: Pin?

}
