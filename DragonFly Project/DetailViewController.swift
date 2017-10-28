//
//  DetailViewController.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/28/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import MapKit
import EventKit

class DetailViewController: UIViewController {
    
    var event:NSDictionary = NSDictionary()
    var eventImage:UIImage = UIImage()
    var eventId:NSString = ""
    let eventStore = EKEventStore()
    var calendar: EKCalendar!
    var locationString:String = ""
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var mapVIew: MKMapView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var respondToEvent: UIButton!
    
    func configureView() {
        // Update the user interface for the detail item.
        if event.allKeys.count == 0 {
            self.view.isHidden = true
        }else{
            self.view.isHidden = false
            
            eventImageView.image = eventImage
            
            eventName.text = event["name"] as? String
            eventDescription.text = event["description"] as! String
            
            let location:NSDictionary = event["location"] as! NSDictionary
            
            let name:String = (location["name"] as? String)!
            let address:String = (location["address"] as? String)!
            let city:String = (location["city"] as? String)!
            let state:String = (location["state"] as? String)!
            
            locationString = "\(name), \(address), \(city), \(state)"
            eventLocation.text = locationString
            
            eventDate.text = "10-02-2017"
            addBottomSheetView()
            loadMapView(locationString: state)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    func addBottomSheetView() {
        let bottomSheetVC = ScrollableBottomSheetViewController()
        
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        bottomSheetVC.commentsArray = event["comments"] as! NSArray
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    func loadMapView(locationString:String){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) { (placeMarkArray, error) in
            let placeMark = placeMarkArray![0]
            
            let region = MKCoordinateRegionMakeWithDistance((placeMark.location?.coordinate)!, 800, 800)
            
            self.mapVIew.setRegion(self.mapVIew.regionThatFits(region), animated: true)
            
            // Add an annotation
            let point = MKPointAnnotation()
            point.coordinate = (placeMark.location?.coordinate)!
            point.title = placeMark.name
            
            self.mapVIew.addAnnotation(point)
        }
    }
    
    @IBAction func addEvent(_ sender: Any) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            saveEvent()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            let alertController = UIAlertController(title: "Access Denied", message: "Go to settings and allow access to calendar", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                self.saveEvent()
            }
        })
    }
    
    func saveEvent(){
        print(getCalendar() as Any)
        let newEvent = EKEvent(eventStore: eventStore)
        
        newEvent.calendar = getCalendar()
        
        newEvent.title = event["name"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = (event["date"] as! String)
        
        let dateSubstring = dateString.split(separator: "T", maxSplits: 3, omittingEmptySubsequences: true)
//        let date = dateFormatter.date(from: dateSubstring.s)
        
        print(dateSubstring as Any)
//        newEvent.startDate = date
//        newEvent.endDate = date
        newEvent.isAllDay = true
        
        newEvent.location = locationString
        
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
            let alert = UIAlertController(title: "Event saved", message: "Successfully", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "dismiss", style: .cancel, handler: nil)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "dismiss", style: .cancel, handler: nil)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getCalendar() -> EKCalendar? {
        let defaults = UserDefaults.standard
        
        if let id = defaults.string(forKey: "calendarID") {
            return eventStore.calendar(withIdentifier: id)
        } else {
            let calendar = EKCalendar(for: .event, eventStore: self.eventStore)
            
            calendar.title = "DragonFly"
            calendar.cgColor = UIColor.red.cgColor
            calendar.source = eventStore.defaultCalendarForNewEvents?.source
            do{
                try eventStore.saveCalendar(calendar, commit: true)
            }catch{
                
            }
            
            defaults.set(calendar.calendarIdentifier, forKey: "calendarID")
            
            return calendar
        }
    }
    
    @IBAction func respondToEvent(_ sender: Any) {
        
    }
}

