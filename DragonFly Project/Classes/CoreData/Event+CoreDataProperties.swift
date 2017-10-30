//
//  Event+CoreDataProperties.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/29/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var name: String?
    @NSManaged public var eventDescription: String?
    @NSManaged public var id: String?
    @NSManaged public var date: String?
    @NSManaged public var image: NSData?
    @NSManaged public var status: Bool
    @NSManaged public var imageId: String?
    @NSManaged public var location: Location?
    @NSManaged public var comment: NSSet?

}

// MARK: Generated accessors for comment
extension Event {

    @objc(addCommentObject:)
    @NSManaged public func addToComment(_ value: Comment)

    @objc(removeCommentObject:)
    @NSManaged public func removeFromComment(_ value: Comment)

    @objc(addComment:)
    @NSManaged public func addToComment(_ values: NSSet)

    @objc(removeComment:)
    @NSManaged public func removeFromComment(_ values: NSSet)

}
