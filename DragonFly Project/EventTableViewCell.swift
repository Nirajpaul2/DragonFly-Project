//
//  EventTableViewCell.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/28/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    @IBOutlet weak var locationName: UILabel!
    
    @IBOutlet weak var locationAddress: UILabel!
    
    @IBOutlet weak var locationCity: UILabel!
    
    @IBOutlet weak var locationState: UILabel!
    
    @IBOutlet weak var eventDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
