//
//  EventClass.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/30/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class LocationClass{
    let name:String
    let address:String
    let city:String
    let state:String
    
    init(name:String,address:String,city:String,state:String) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
    }
}

class CommentClass{
    let from:String
    let text:String
    
    init(from:String,text:String) {
        self.from = from
        self.text = text
    }
}

class EventClass: NSObject {
    let name: String
    let eventDescription: String
    let date: String
    let image: NSData
    let status: Bool
    let imageId: String
    let location: LocationClass
    let comment:[CommentClass]
    
    init(name:String,eventDescription:String,date:String,image:NSData,status:Bool,imageId:String,location:LocationClass,comment:[CommentClass]) {
        self.name = name
        self.eventDescription = eventDescription
        self.date = date
        self.image = image
        self.status = status
        self.imageId = imageId
        self.location = location
        self.comment = comment
    }
}
