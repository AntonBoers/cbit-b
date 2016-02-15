//
//  LoginViewController.swift
//  CBITB
//
//  Created by Thomas Bjørk on 21/01/2016.
//  Copyright © 2016 Thomas Bjørk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBAction func Indstillinger(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var indstillingerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForToken", name: UIApplicationWillEnterForegroundNotification, object: nil) //Kalder funktionen 'checkForToken' efter app'en returner fra foreground
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForToken() {
        //Checker at token area ikke er tomt og at token ikke er et empty string: hvis ja, ændre UI
        if(NSUserDefaults.standardUserDefaults().objectForKey("butik_token") != nil)
        {
            if(NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! NSString != "")
            {
                print("OKAY")
                indstillingerButton.hidden = true
                loginButton.hidden = false
            }
        }
        
        
    }
}
