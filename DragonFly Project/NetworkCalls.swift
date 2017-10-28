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

let APIROOT:String = "http://dev.dragonflyathletics.com:1337/api/dfkey/"
let username:String = "anything"
let password:String = "evalpass"

class NetworkCalls: NSObject {
    
    func getAllEvents(completionHandler: @escaping (NSArray?, NSError?) -> ()){
        let urlPath:String = APIROOT + "events"
        
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).authenticate(user: username, password: password).responseJSON{response in
            if (response.result.error == nil){
                // Convert server json response to NSArray
                do {
                    if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSArray {
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
    
    func getMediaForEvent(eventId:String,mediaId:String,completionHandler: @escaping (UIImage?, String?) -> ()){
        
//        DataRequest.addAcceptableImageContentTypes(["image/jpeg"])
        
        let urlPath:String = APIROOT + "events/\(eventId)/media/\(mediaId)"
        
        Alamofire.request(urlPath, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).authenticate(user: username, password: password).responseImage { response in
            
            if response.error == nil {
                let image = response.result.value
                completionHandler(image, nil)
            }
            
            if response.error != nil{
                completionHandler(nil,"error")
            }
        }
    }
}
