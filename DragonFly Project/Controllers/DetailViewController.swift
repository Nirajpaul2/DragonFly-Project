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
    
    var event:Event?
    var eventId:NSString = ""
    let eventStore = EKEventStore()
    var calendar: EKCalendar!
    var locationString:String = ""
    let networkCall = NetworkCalls()
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var mapVIew: MKMapView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var respondToEvent: UIButton!
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if (event?.image != nil) {
            if let image = UIImage(data: (event?.image!)! as Data){
                eventImageView.image = image
            }else{
                eventImageView.image = UIImage(named:"tempImage")!
            }
        }else{
            eventImageView.image = UIImage(named:"tempImage")!
        }
            eventName.text = event?.name
            eventDescription.text = event?.eventDescription
        
        let location:Location = (event?.location)!
            
        let name:String = location.name!
        let address:String = location.address!
        let city:String = location.city!
        let state:String = location.state!
            
            locationString = "\(name), \(address), \(city), \(state)"
            eventLocation.text = locationString
            
            eventDate.text = "10-02-2017"
            addBottomSheetView()
            loadMapView(locationString: state)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func addBottomSheetView() {
        let bottomSheetVC = ScrollableBottomSheetViewController()
        
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        bottomSheetVC.commentsArray = networkCall.getCommentsForEvent(event: event!)
        
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
        
        newEvent.title = event?.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = "10-02-2017"
        
        newEvent.startDate = dateFormatter.date(from: dateString)
        newEvent.endDate = dateFormatter.date(from: dateString)
        
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

