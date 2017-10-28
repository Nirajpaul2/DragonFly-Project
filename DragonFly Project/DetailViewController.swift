//
//  DetailViewController.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/28/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    var event:NSDictionary = NSDictionary()
    var eventImage:UIImage = UIImage()
    var eventId:NSString = ""
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var mapVIew: MKMapView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    
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
            
            let locationString = "\(name), \(address), \(city), \(state)"
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
}

