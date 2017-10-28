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

let APIROOT:String = "http://dev.dragonflyathletics.com:1337/api/dfkey/"
let username:String = "anything"
let password:String = "evalpass"

class NetworkCalls: NSObject {
    
    func getEventsFromNetwork(completionHandler: @escaping (NSArray?, NSError?) -> ()){
        let urlPath:String = APIROOT + "events"
        
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).authenticate(user: username, password: password).responseJSON{response in
            if (response.result.error == nil){
                // Convert server json response to NSArray
                do {
                    if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSArray {
                        
                        // Print out Array
                        completionHandler(convertedJsonIntoArray, nil)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completionHandler([], error)
                }
                
            }else{
                print("error")
                completionHandler([], response.result.error as NSError?)
            }
        }
    }
    
//    func sendButtonTapped(sender: AnyObject) {
//        // Add one parameter
//        let urlWithParams = scriptUrl + "?userName=\(userNameValue!)"
//        // Create NSURL Ibject
//        let myUrl = NSURL(string: urlWithParams);
//
//        // Creaste URL Request
//        let request = NSMutableURLRequest(URL:myUrl!);
//
//        // Set request HTTP method to GET. It could be POST as well
//        request.HTTPMethod = "GET"
//
//        // If needed you could add Authorization header value
//        // Add Basic Authorization
//        /*
//         let username = "myUserName"
//         let password = "myPassword"
//         let loginString = NSString(format: "%@:%@", username, password)
//         let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
//         let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
//         request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
//         */
//
//        // Or it could be a single Authorization Token value
//        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
//
//        // Excute HTTP Request
//        let task = URLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//
//            // Check for error
//            if error != nil
//            {
//                print("error=\(error)")
//                return
//            }
//
//            // Print out response string
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("responseString = \(responseString)")
//
//
//            // Convert server json response to NSDictionary
//            do {
//                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
//
//                    // Print out dictionary
//                    print(convertedJsonIntoDict)
//
//                    // Get value by key
//                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
//                    print(firstNameValue!)
//
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//
//        }
//
//        task.resume()
//
//    }
}
