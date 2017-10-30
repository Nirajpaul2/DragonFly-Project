//
//  LoginViewController.swift
//  DragonFly Project
//
//  Created by Aditya Emani on 10/30/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
var userName:String = ""
var password:String = ""
class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginAction(_ sender: Any) {
        if usernameTF.text != "" && passwordTF.text == "evalpass" {
            userName = usernameTF.text!
            password = passwordTF.text!
            performSegue(withIdentifier: "loadApp", sender: self)
        }else{
            let acs: UIAlertController = UIAlertController(title: "Could not login!", message: "Check password", preferredStyle: .actionSheet)
            
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            acs.addAction(ok)
            
            self.present(acs, animated: true, completion: nil)
        }
    }
}
