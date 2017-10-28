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
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var eventArray:NSArray = []
    var eventImage:UIImage = UIImage()
    
    let networkCall = NetworkCalls()
    var cellImage:[UIImage] = []
    var event:NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkCall.getAllEvents { (array, error) in
            self.eventArray = array!
            if self.eventArray.count != 0{
                for i in 0..<self.eventArray.count{
                    let event:NSDictionary = self.eventArray[i] as! NSDictionary
                    let imageArray:NSArray = event["images"] as! NSArray
                    if imageArray.count != 0{
                        let imageDictionary:NSDictionary = imageArray[0] as! NSDictionary
                        self.networkCall.getMediaForEvent(eventId: event["id"] as! String, mediaId: imageDictionary["id"] as! String, completionHandler: { (image, errorString) in
                            if errorString != "error"{
                                self.cellImage.append(image!)
                            }else{
                                self.cellImage.append(UIImage(named:"tempImage")!)
                            }
                            if i == (self.eventArray.count - 1){
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let secondaryAsNavController:UINavigationController = (segue.destination as? UINavigationController)!
            let destinationVC = secondaryAsNavController.topViewController as? DetailViewController
            
            destinationVC?.event = event
            destinationVC?.eventImage = eventImage
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
        
        let event:NSDictionary = eventArray.object(at: indexPath.row) as! NSDictionary
        
        cell.eventImageView.image = cellImage[indexPath.row]
        
        cell.eventName.text = event["name"] as? String
        cell.eventDescription.text = event["description"] as! String
        
        let location:NSDictionary = event["location"] as! NSDictionary
        
        let name:String = (location["state"] as? String)!
        let address:String = (location["address"] as? String)!
        let city:String = (location["city"] as? String)!
        let state:String = (location["state"] as? String)!
        
        cell.locationName.text = "\(name), \(address), \(city), \(state)"
        
        cell.eventDate.text = "10-02-2017"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        event = eventArray[indexPath.row] as! NSDictionary
        eventImage = cellImage[indexPath.row]
    }
}

