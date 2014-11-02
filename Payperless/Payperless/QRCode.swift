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
    
    var cardNumber : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var qrCode = createQRForString(cardNumber)
        qrCodeImage.image = createNonInterpolatedUIImageFromCIImage(qrCode, scale:2*UIScreen.mainScreen().scale)
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


}
