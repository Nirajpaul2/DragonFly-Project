//
//  Comment+CoreDataProperties.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/29/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var from: String?
    @NSManaged public var text: String?
    @NSManaged public var event: Event?

}
