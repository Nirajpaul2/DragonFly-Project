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
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            makeNetworkCall()
    }
    
    func makeNetworkCall(){
        showActivityIndicatory(uiView: self.view)
        networkCall.getAllEvents { (array, error) in
            self.stopActivityIndicator()
            if array?.count == 0{
                self.showAlert()
            }else{
                self.eventArray = array!
                    self.tableView.reloadData()
            }
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        uiView.isUserInteractionEnabled = false
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func stopActivityIndicator(){
        self.view.isUserInteractionEnabled = true
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
    
    func showAlert(){
        let actionSheet: UIAlertController = UIAlertController(title: "Error fetching information from Server", message: "", preferredStyle: .actionSheet)
        
        let one = UIAlertAction(title: "Try again?", style: .default) { _ in
                self.makeNetworkCall()
        }
        actionSheet.addAction(one)
        
        let two = UIAlertAction(title: "Load Offline Data", style: .default)
        { _ in
            self.eventArray = self.networkCall.fetchEventsFromCoreData()
            if self.eventArray.count == 0 {
                self.makeNetworkCall()
            }else{
                self.tableView.reloadData()
            }
        }
        actionSheet.addAction(two)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlert2(){
        let actionSheet: UIAlertController = UIAlertController(title: "Displaying Local Data", message: "Fetch data from Server?", preferredStyle: .actionSheet)
        
        let one = UIAlertAction(title: "Yes", style: .default) { _ in
            self.makeNetworkCall()
        }
        actionSheet.addAction(one)
        
        let two = UIAlertAction(title: "No", style: .cancel)
        actionSheet.addAction(two)
        self.present(actionSheet, animated: true, completion: nil)
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
                cell.eventImageView.image = UIImage(named:"tempImage")!
            }
        }else{
                cell.eventImageView.image = UIImage(named:"tempImage")!
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
    
    @IBAction func reloadData(_ sender: Any) {
        makeNetworkCall()
    }
    
    
}

