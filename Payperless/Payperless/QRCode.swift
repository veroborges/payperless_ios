//
//  QRCode.swift
//  Payperless
//
//  Created by Veronica Borges on 11/1/14.
//  Copyright (c) 2014 Veronica Borges. All rights reserved.
//

import UIKit

class QRCode: UIViewController {
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var backgroundMaskView: UIView!
    var cardNumber : String = ""
    var amount : String = ""

    var done = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        self.dialogView.layer.cornerRadius = 5
        let queue = NSOperationQueue()
        self.amountLabel.text = "$" + self.amount
        animator = UIDynamicAnimator(referenceView: view)

        queue.addOperationWithBlock() {
            // do something in the background
            var qrCode = self.createQRForString(self.cardNumber)
            self.qrCodeImage.image = self.createNonInterpolatedUIImageFromCIImage(qrCode, scale:UIScreen.mainScreen().scale)
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                NSLog("Done")
                self.done = true
                self.panRecognizer.enabled = true
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        views = (frontView: self.amountView, backView: self.qrView)

        spinDialog();
    }
    
    var spinTimes = 1.0
    var views : (frontView: UIView, backView: UIView) = (UIView(), UIView())
    func spinDialog(){
        
        let transitionOptions = UIViewAnimationOptions.TransitionFlipFromLeft
        let duration =  spinTimes/10.0
        UIView.transitionFromView(views.frontView, toView: views.backView, duration: duration, options: transitionOptions){
            (success) -> Void in
                var oldBackView = self.views.backView
                self.views.backView = self.views.frontView
                self.views.frontView = oldBackView
            
                if (self.spinTimes < 10.0){
                    if (self.spinTimes > 5.0){
                        self.spinTimes += 1.5
                    }else if (self.spinTimes > 7.0){
                        self.spinTimes += 1.8
                    }else{
                        self.spinTimes += 0.5
                    }
                    
                    self.spinDialog()
                }else{
                    if (self.views.frontView == self.amountView){
                        self.spinDialog()
                        return
                    }
                    
                    springComplete(0.4, { () -> Void in
                        self.processingLabel.alpha = 0
                        self.processingLabel.text = "Place the QR code in front of the reader. Slide up when done"
                        self.processingLabel.alpha = 1
                        },{ (success) -> Void in
                            
                    })
                    
                    
                }
        }
    }
    
    func createQRForString(qrString : String) -> CIImage
    {
        // Need to convert the string to a UTF-8 encoded NSData object
        var stringData = qrString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create the filter
        var qrFilter = CIFilter(name: "CIQRCodeGenerator");
        NSLog(qrString)
        // Set the message content and error-correction level
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Send the image back
        return qrFilter.outputImage
    }
    
    func createNonInterpolatedUIImageFromCIImage(image : CIImage, scale:CGFloat) -> UIImage
    {
        // Render the CIImage into a CGImage
       
        let context = CIContext(options:nil)
        var cgImage = context.createCGImage(image,fromRect:image.extent())
        
        // Now we'll rescale using CoreGraphics
        UIGraphicsBeginImageContext(CGSizeMake(image.extent().size.width * scale, image.extent().size.width * scale));
        
        var contextRef = UIGraphicsGetCurrentContext();
        
        // We don't want to interpolate (since we've got a pixel-correct image)
        CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
        CGContextDrawImage(contextRef, CGContextGetClipBoundingBox(contextRef), cgImage);
        // Get the image out
        var scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // Tidy up
        
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    @IBAction func handleGesture(sender: AnyObject) {
        if (done){
            let myView = dialogView
            let location = sender.locationInView(view)
            let boxLocation = sender.locationInView(dialogView)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeBehavior(snapBehavior)
                
                let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
                attachmentBehavior.frequency = 0
                
                animator.addBehavior(attachmentBehavior)
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = location
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeBehavior(attachmentBehavior)
                
                snapBehavior = UISnapBehavior(item: myView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                let translation = sender.translationInView(view)
                if translation.y < 75 {
                    animator.removeAllBehaviors()
                    
                    var gravity = UIGravityBehavior(items: [dialogView])
                    gravity.gravityDirection = CGVectorMake(0, -10)
                    animator.addBehavior(gravity)
                    
                    delay(0.5){
                        spring(0.5, {
                            self.processingLabel.text = "Congrats! You're transaction is complete"
                            self.processingLabel.transform = CGAffineTransformMakeTranslation(0, -500)
                        })
                    }
                    
                }
            }
        }
    }

}
