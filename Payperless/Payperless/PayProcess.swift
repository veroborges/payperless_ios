//
//  PayProcess
//  Payperless
//
//  Created by Veronica Borges on 11/1/14.
//  Copyright (c) 2014 Veronica Borges. All rights reserved.
//

import UIKit
import LocalAuthentication

class PayProcess: UIViewController {
    
    @IBOutlet weak var merchantHeaderImg: UIImageView!
    @IBOutlet weak var numberPadView: UIView!
    
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var amountLabelInit: UILabel!
    
    var listOFLabels = [UILabel]()
    var isDecimal = false
    var alteredFirstDec = false
    var removedSecDec = false
    var merchantID = "1234"
    var userID = "1234"
    
    @IBAction func pressedNumber(sender: UIButton) {
        var title = sender.titleLabel?.text
        if (isDecimal){
            var firstDec = listOFLabels[listOFLabels.count-2].text
            animateBack(true)
            
            if (firstDec == "0" && !alteredFirstDec){
                animateBack(true)
            }
            
            addNewLabel(title!)
            
            if (firstDec == "0" && !alteredFirstDec){
                addNewLabel("0")
            }
        }else{
            addNewLabel(title!)
            if (title == "."){
                isDecimal = true
                addNewLabel("0");
                addNewLabel("0");
            }
        }

    }
    
    @IBAction func confirmPay(sender: AnyObject) {
        authenticateUser(processPayment)
        
    }
    func authenticateUser(callback: Bool -> Void){
        // Get the local authentication context.
        let context : LAContext = LAContext()
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        var reasonString = "Authentication is needed to confirm payment."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                (success: Bool, evalPolicyError: NSError?) -> Void in
                if (success){
                    callback(true)
                }else{
                    callback(false)
                }
                
            })]
        }
    }
    
    func processPayment(success:Bool){
        if (success){
            var amount = ""
            for label in listOFLabels {
                if (label.text != "$"){
                    amount += label.text!
                }
            }
            PayperlessAPI.issueStoreCard(amount, merchantID: merchantID, userID: userID) {
                (result) -> Void in
                self.performSegueWithIdentifier("showQRCode", sender:result["card_number"])
            }
        }
    }
    
    func addNewLabel(title:NSString){
        var lastFrame = listOFLabels.last!.frame
        let label = UILabel(frame: CGRectMake(lastFrame.origin.x + lastFrame.size.width/2 , 239, 22, 45))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.font = UIFont (name: "Helvetica-Bold", size: 39)
        label.textColor = UIColor.whiteColor()
        label.alpha = 0
        self.view.addSubview(label)
        
        spring(0.5, {
            self.animateNewCharacter(label)
        })
    }
    
    func animateNewCharacter(label:UILabel){
        for l in listOFLabels {
            var newFrame = l.frame
            newFrame.origin.x = l.frame.origin.x - newFrame.size.width/2
            l.frame = newFrame
        }
        label.alpha = 1
        listOFLabels.append(label)
    }
    
    func animateBack(dontCheck : Bool){
        var label = listOFLabels.last!
        label.alpha = 0
        
        if (!dontCheck){
            if (label == "."){
                isDecimal = false
                alteredFirstDec = false
            }
            
            if (isDecimal && !alteredFirstDec && listOFLabels[listOFLabels.count-2].text == "0"  && listOFLabels[listOFLabels.count-1].text == "0"){
                    NSLog("in here")
                  listOFLabels.removeLast()
                  listOFLabels.removeLast()
                
                isDecimal = false
                alteredFirstDec = false
            }
        }
        
        listOFLabels.removeLast()

        for l in listOFLabels {
            var newFrame = l.frame
            newFrame.origin.x = l.frame.origin.x + newFrame.size.width/2
            l.frame = newFrame
        }
        
        if (!dontCheck){
            if (isDecimal && listOFLabels[listOFLabels.count-2].text == "." && !removedSecDec){
                addNewLabel("0")
                removedSecDec = true
                alteredFirstDec = false
            }else if (isDecimal && listOFLabels[listOFLabels.count-1].text == "."){
                listOFLabels.removeLast()
            }
        }
        

    }
    
    @IBAction func pressedBackspace(sender: UIButton) {
        if (listOFLabels.count > 1){
            spring(0.5, {
                self.animateBack(false)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showQRCode") {
            var qrVC = segue.destinationViewController as QRCode;
            qrVC.cardNumber = sender as String!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listOFLabels.append(dollarLabel)
        // Do any additional setup after loading the view, typically from a nib.
    }

}

