//
//  ViewController.swift
//  CBITB
//
//  Created by Thomas Bjørk on 14/01/2016.
//  Copyright © 2016 Thomas Bjørk. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
class ViewController: UIViewController {

    var butikToken = ""
    
    var captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var stillImageOutput = AVCaptureStillImageOutput()
    var sampleBuffer: CMSampleBuffer!
    
    var error : Error!
    
    var blank : UIView!
    
    var launch = false
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    @IBAction func takePicture(sender: AnyObject) {
        tagBillede.hidden = true
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
       
        captureSession.removeOutput(stillImageOutput)
        
        captureSession.addOutput(stillImageOutput)

        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
            var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            var dataProvider = CGDataProviderCreateWithCFData(imageData)
            var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
            
            var imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width ,height: UIScreen.mainScreen().bounds.height)
                
            Variables.image = imageView
            
                
            var testVar = UIImagePNGRepresentation(image)!
            let base64string = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            let parameters = [
                "img": base64string
            ]
            
            Alamofire.upload(Alamofire.Method.POST, "http://webdk200.eadministration.dk/tokenbilag.asp?token=" + self.butikToken, data: testVar)
            self.tagBillede.hidden = false
            })

        }
   
    }
    @IBOutlet var cameraView: UIView!
    
    @IBOutlet var tagBillede: UIButton!
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkToken", name: UIApplicationWillEnterForegroundNotification, object: nil) //Caller funktionen 'checkForToken' når appen kommer i foreground
        
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("butik_token") != nil)
        {
            if(NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! NSString != "")
            {
                //trimmer token
                butikToken = NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! String
                butikToken = butikToken.stringByReplacingOccurrencesOfString(" ", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("{", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("}", withString: "")
            }
        }
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") && butikToken != "")
        {
            //Kald funktion som checker om token er valid og derefter(hvis den er valid) kalder kamera funktion
            checkToken()
        }
        else
        {
            //first launch
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            performSegueWithIdentifier("camera", sender: self)
            
        }    
        
        
        
}
    func checkToken(){
        
        butikToken = NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! String
        
        //Kald funktion checker om token er valid og derefter(hvis den er valid) kalder kamera funktion
        let urlString = "http://webdk200.eadministration.dk/tokenbilag.asp?token=" + butikToken  //JSON url
        if let url = NSURL(string: urlString){ //checker at URL er valid
            let url = NSURL(string: urlString)
            let htmlString = try! NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
            if(htmlString == "TOKEN OK"){
                if(launch == false)
                {
                    launch = true
                    startCamera()
                    
                }
                tagBillede.hidden = false
            }
            else if(htmlString == "TOKEN ERROR"){
                tagBillede.hidden = true
                
                let alert = UIAlertController(title: "Forkert token", message: "Den token du har indtastet under Indstillinger matcher ikke noget i vores database\n Gå ind i Indstillinger og sikre dig, at du har skrevet den korrekt"
                    , preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Gå Til Indstillinger", style: UIAlertActionStyle.Default, handler: { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
                
                presentViewController(alert, animated: true, completion: nil) //viser alert'en
            }
        }    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    func startCamera()
    {

        if(captureDevice == nil)
        {
            let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
            if let captureDevice = devices.first as? AVCaptureDevice  {
                try! captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                captureSession.startRunning()
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                
                if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                    previewLayer.bounds = view.bounds
                    previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    //let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
                    cameraView.layer.addSublayer(previewLayer)
                }
                
                
                
                
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

