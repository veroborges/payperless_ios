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
    @IBOutlet weak var headerMask: UIView!
    @IBOutlet weak var backgroundMaskView: UIView!
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var greenContainer: UIView!
    @IBOutlet weak var dollarLabel: UILabel!

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountHelperText: UILabel!
    
    @IBOutlet weak var processingLabel: UILabel!
    
    var listOFLabels = [UILabel]()
    var isDecimal = false
    var alteredFirstDec = false
    var removedSecDec = false
    var merchantID = "1234"
    var userID = "1"
    var cardNumber = ""
    var issueCardDone = false
    var dialogAnimationDone = false
    
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
        authenticateUser(){
            (success) -> Void in
                self.processPayment(success)
        }

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
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (success){
                        callback(success)
                    }else{
                        callback(success)
                    }
                })

                
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
            
            animateProcessing(amount)

            PayperlessAPI.issueStoreCard(amount, merchantID: merchantID, userID: userID) {
                (results) -> Void in
                    self.cardNumber = results["card_number"] as String!
                    self.issueCardDone = true
                    self.checkIfDone()
            }
        }
    }
    

    func animateProcessing(amount:String){
        for label in listOFLabels {
            if (label.text != "$"){
                label.removeFromSuperview()
            }
        }
        
        dollarLabel.text = "$" + amount
        dollarLabel.frame = CGRectMake(0, 110, 323, 58)
        amountLabel.text = "Amount"
        amountLabel.frame = CGRectMake(0, 25, 323, 25)
        self.processingLabel.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeTranslation(0, -100))
        self.processingLabel.alpha = 0
        
        springComplete(0.8, {
            self.numberPadView.alpha = 0
            self.numberPadView.hidden = true
            self.amountHelperText.alpha = 0
            self.amountHelperText.hidden = true
            self.dialogView.frame = CGRectMake(26, 100, 323, 400)
            self.dialogView.layer.cornerRadius = 5
            self.processingLabel.hidden = false
            self.processingLabel.alpha = 1
            
            self.dollarLabel.font = UIFont(name: "Helvetica-Bold", size: 60)
            self.dollarLabel.transform = CGAffineTransformMakeTranslation(0, -20)
            self.processingLabel.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0))
        }, { (Bool) -> Void in
            self.dialogAnimationDone = true
            self.checkIfDone()
        })
    }
    
    func checkIfDone(){
        if (self.dialogAnimationDone && self.issueCardDone)
            self.performSegueWithIdentifier("showQRCode", sender:amount)
    }
    
    func addNewLabel(title:NSString){
        var lastFrame = listOFLabels.last!.frame
        let label = UILabel(frame: CGRectMake(lastFrame.origin.x + lastFrame.size.width/2 , 110, 22, 45))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.font = UIFont (name: "Helvetica-Bold", size: 39)
        label.textColor = UIColor.whiteColor()
        label.alpha = 0
        self.greenContainer.addSubview(label)
        
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
            qrVC.cardNumber = self.cardNumber
            qrVC.amount = sender as String!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        listOFLabels.append(dollarLabel)
    }

}

