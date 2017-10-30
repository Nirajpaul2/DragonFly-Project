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
import MessageUI

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: Event Details VC Methods
    //Load view on viewDidLoad
    func configureView() {
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
        if (event?.status)!{
            respondToEvent.isEnabled = false
            self.respondToEvent.setTitle("Attending",for: .normal)
        }else{
            self.respondToEvent.setTitle("Respond",for: .normal)
        }
        
        self.networkCall.getStatusOfEvent(eventId: (self.event?.id)!, completionHandler: { (responseStatus, error) in
        })
    }
    
    //Add Comments Section at the bottom
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
    
    // MARK: Mapview Method
    //Load MapView if there is network
    func loadMapView(locationString:String){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) { (placeMarkArray, error) in
            if let placeMark = placeMarkArray?[0]{
                let region = MKCoordinateRegionMakeWithDistance((placeMark.location?.coordinate)!, 800, 800)
                
                self.mapVIew.setRegion(self.mapVIew.regionThatFits(region), animated: true)
                
                // Add an annotation
                let point = MKPointAnnotation()
                point.coordinate = (placeMark.location?.coordinate)!
                point.title = placeMark.name
                
                self.mapVIew.addAnnotation(point)
            }
        }
    }
    
    // MARK: Calendar Event Methods
    //Check for calendar access
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
    
    //Request access to calendar
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                self.saveEvent()
            }
        })
    }
    
    //Create an event in calendar
    func saveEvent(){
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
    
    //Create/Get Calendar
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
    
    //Respond to Event on user button click
    @IBAction func respondToEvent(_ sender: Any) {
        let actionSheet: UIAlertController = UIAlertController(title: "Would you like to Attend Event?", message: event?.name, preferredStyle: .actionSheet)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
            self.networkCall.updateStatusForEvent(eventId: (self.event?.id)!, status:true)
            self.networkCall.putStatusOfEvent(eventId: (self.event?.id)!, status: true, completionHandler: { (status, error) in
                self.respondToEvent.setTitle("Attending",for: .normal);             self.respondToEvent.isEnabled = false
                
                let acs: UIAlertController = UIAlertController(title: "Update saved to local database", message: "Error saving to server, we will try to save your update in background", preferredStyle: .actionSheet)
                
                let ok = UIAlertAction(title: "Ok", style: .cancel)
                acs.addAction(ok)
                
                self.present(acs, animated: true, completion: nil)
            })
        }
        actionSheet.addAction(yes)
        
        let no = UIAlertAction(title: "No", style: .default)
        { _ in
            self.networkCall.updateStatusForEvent(eventId: (self.event?.id)!, status:false)
            self.networkCall.putStatusOfEvent(eventId: (self.event?.id)!, status: false, completionHandler: { (status, error) in
            })
        }
        actionSheet.addAction(no)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: Share via email Action Methods
    //Send email button action
    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    //Configure email controller
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["prasaadem@tamu.edu"])
        let subjectString = (event?.name)!+" - "+(event?.date)!
        mailComposerVC.setSubject(subjectString)
        let bodyString = "Event Description:\n"+(event?.eventDescription)!+"\n"+"Location: \n"+locationString
        mailComposerVC.setMessageBody(bodyString, isHTML: false)
        let imageData: NSData = UIImageJPEGRepresentation(eventImageView.image!, 1)! as NSData
        mailComposerVC.addAttachmentData(imageData as Data, mimeType: "image/jpeg", fileName: "image")
        return mailComposerVC
    }
    
    //Error message in case of email failure
    func showSendMailErrorAlert() {
        let acs: UIAlertController = UIAlertController(title: "Could not send emails from this device", message: "Setup email client in settings", preferredStyle: .actionSheet)
        
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        acs.addAction(ok)
        
        self.present(acs, animated: true, completion: nil)
    }
    
    //MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

