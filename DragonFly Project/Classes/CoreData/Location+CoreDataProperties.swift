//
//  Location+CoreDataProperties.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/29/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var state: String?
    @NSManaged public var city: String?
    @NSManaged public var address: String?
    @NSManaged public var name: String?
    @NSManaged public var event: Event?

}
