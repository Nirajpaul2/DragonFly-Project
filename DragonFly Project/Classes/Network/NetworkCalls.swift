//
//  NetworkCalls.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/28/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData

let APIROOT:String = "http://dev.dragonflyathletics.com:1337/api/dfkey/"
let username:String = "anything"
let password:String = "evalpass"

var events:[Event] = []

class NetworkCalls: NSObject {
    
    func getAllEvents(completionHandler: @escaping (NSArray?, NSError?) -> ()){
        let urlPath:String = APIROOT + "events"
        
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).authenticate(user: username, password: password).responseJSON{response in
            if (response.result.error == nil){
                do {
                    if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSArray {
//                        self.saveEventsToCoreData(eventsArray: convertedJsonIntoArray)
                        completionHandler(convertedJsonIntoArray, nil)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }else{
                print("error")
                completionHandler([], response.result.error as NSError?)
            }
        }
    }
    
    func getMediaForEvent(eventId:String,mediaId:String,completionHandler: @escaping (UIImage?) -> ()) {
        let urlPath:String = APIROOT + "events/\(eventId)/media/\(mediaId)"
        
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).authenticate(user: username, password: password).responseImage { response in
            if response.error == nil {
                completionHandler(response.result.value)
            }
            if response.error != nil{
                completionHandler(UIImage(named:"tempImage")!)
            }
        }
    }
    
    
    func saveEventsToCoreData(eventsArray:NSArray,completionHandler: @escaping (NSArray?) -> ()){
        
        deleteAllDataFromCoreData()
        for singleEvent in eventsArray{
            let eventDictionary = singleEvent as! NSDictionary
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let eventEntity =
                NSEntityDescription.entity(forEntityName: "Event",
                                           in: managedContext)!
            
            let event:Event = Event(entity: eventEntity, insertInto: managedContext)
            
            event.id = eventDictionary["id"] as? String
            event.name = eventDictionary["name"] as? String
            event.eventDescription = eventDictionary["description"] as? String
            event.date = eventDictionary["date"] as? String
            
            let location:NSDictionary = eventDictionary["location"] as! NSDictionary
            
            let locationEntity =
                NSEntityDescription.entity(forEntityName: "Location",
                                           in: managedContext)!
            
            let l:Location = Location(entity: locationEntity, insertInto: managedContext)
            
            l.name = (location["name"] as? String)!
            l.address = (location["address"] as? String)!
            l.city = (location["city"] as? String)!
            l.state = (location["state"] as? String)!
            
            event.location = l
            
            let commentEntityArray:NSSet = []
            let commentsArray = eventDictionary["comments"] as! NSArray
            
            for c in commentsArray{
                let temp = c as! NSDictionary
                
                let commentEntity =
                    NSEntityDescription.entity(forEntityName: "Comment",
                                               in: managedContext)!
                
                let com:Comment = Comment(entity: commentEntity, insertInto: managedContext)
                com.from = temp["from"] as? String
                com.text = temp["text"] as? String
                commentEntityArray.adding(com)
            }
            
            event.comment = commentEntityArray
            
            let imagesArray = eventDictionary["images"] as! NSArray
            if imagesArray.count != 0{
                let imageDictionary:NSDictionary = imagesArray[0] as! NSDictionary
                event.imageId = imageDictionary["id"] as? String
            }else{
                event.imageId = ""
            }
            appDelegate.saveContext()
        }
        let array = fetchEventsFromCoreData()
        completionHandler(array)
    }
    
    func fetchEventsFromCoreData() -> NSArray{
        var results:NSArray = []
        let fetchRequest:NSFetchRequest<Event> = Event.fetchRequest()
        do{
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return results
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let data = try managedContext.fetch(fetchRequest)
            results = NSArray(array: data)
            print(results.count)
        }catch{
            print("error: \(error)")
        }
        return results
    }

    func deleteAllDataFromCoreData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        let batchDeleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        do {
            try managedContext.execute(batchDeleteRequest1)
            try managedContext.execute(batchDeleteRequest2)
            try managedContext.execute(batchDeleteRequest3)
        } catch {
            print("error: \(error)")
        }
        
    }
}
