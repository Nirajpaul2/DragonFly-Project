//
//  MasterViewController.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/28/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var eventArray:NSArray = []
    var selectedEvent:Event?
    let networkCall = NetworkCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventArray = networkCall.fetchEventsFromCoreData()
        if eventArray.count == 0 {
            networkCall.getAllEvents { (array, error) in
                if array?.count == 0{
                    
                }else{
                    self.networkCall.saveEventsToCoreData(eventsArray: array!, completionHandler: { (coreDataEvents) in
                        self.eventArray = coreDataEvents!
                        self.tableView.reloadData()
                    })
                }
            }
        }else{
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEvent" {
            let destinationVC = segue.destination as? DetailViewController
            destinationVC?.event = selectedEvent
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell
        
        let event:Event = eventArray.object(at: indexPath.row) as! Event
    
        if (event.image != nil) {
            if let image = UIImage(data: (event.image! as NSData) as Data){
                cell.eventImageView.image = image
            }else{
                print("Came Here")
                cell.eventImageView.image = UIImage(named:"tempImage")!
            }
        }else{
            if event.imageId != ""{
//                networkCall.getMediaForEvent(eventId: event.id!, mediaId: event.imageId!, completionHandler: { (eventImage) in
//                    event.image = UIImageJPEGRepresentation(eventImage!, 1)! as NSData
//                })
                cell.eventImageView.image = UIImage(named:"tempImage")!
            }else{
                cell.eventImageView.image = UIImage(named:"tempImage")!
            }
            
        }
        
        cell.eventName.text = event.name
        cell.eventDescription.text = event.eventDescription
        
        let l:Location = event.location!
        
        cell.locationName.text = l.name!+" "+l.address!+" "+l.city!+" "+l.state!
        cell.eventDate.text = "10-02-2017"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 520.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = eventArray.object(at: indexPath.row) as? Event
        performSegue(withIdentifier: "showEvent", sender: self)
    }
}

