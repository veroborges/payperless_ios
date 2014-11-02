//
//  PayperlessAPI.swift
//  Payperless
//
//  Created by Veronica Borges on 11/1/14.
//  Copyright (c) 2014 Veronica Borges. All rights reserved.
//

import Foundation
var host = "http://localhost:3000"

class PayperlessAPI: NSObject {

    var query = String()
    
    
    /*****
    # POST /api/issue_store_card
    # params:
    # 	amount
    # 	merchantId
    # 	userId, session token or some sort of auth
    # returns:
    # 	qrcode image path or cleartext number,card_id
    ****/
    class func issueStoreCard(amount:String, merchantID:String, userID:String, callback:(NSDictionary) -> Void){
        let params = "merchant_id=\(merchantID)&amount=\(amount)&user_id=\(userID)"
        HTTPPostJSON("/api/issue_store_card", dataString: params) {
            (result) -> Void in
                //callback(result)
            callback(["card_number":"6050110010032766608","balance":"10.00"])
        }
    }

    /*****
    # GET /api/check_card_balance
    # params:
    # 	cardID
    # returns:
    # 	balance
    ****/
    class func checkCardBalance(cardID:String, callback:(NSDictionary) -> Void) {
        let params = "card_id=\(cardID)"
        HTTPGetJSON("/api/check_card_balance", dataString: params) {
            (result) -> Void in
            //callback(result)
            callback(["card_number":"6050110010032766608","balance":"10.00"])
        }
        
    }
    
    /*****
    # GET /api/get_all_transactions
    # params:
    # 	userID
    # returns:
    # 	array of transactions
    ****/
    class func getAllTransactions(userID:String, callback:(NSDictionary) -> Void) {
        let params = "user_id=\(userID)"
        HTTPGetJSON("/api/get_all_transactions", dataString: params, callback)
    }
    
    /** HELPER FUNCTIONS FOR POST/GET ***/
    
    class func HTTPPostJSON(urlPath: String, dataString :String, callback: (NSDictionary) -> Void) {
            var request = NSMutableURLRequest(URL: NSURL(string: "\(host)\(urlPath)")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.HTTPBody = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            HTTPsendRequest(request, callback)
    }
    
    
    class func HTTPGetJSON(urlPath: String, dataString:String, callback: (NSDictionary) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(host)\(urlPath)?\(dataString)")!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        HTTPsendRequest(request, callback)
    }
    
    class func HTTPsendRequest(request: NSMutableURLRequest,callback: (NSDictionary) -> Void) {
            let task = NSURLSession.sharedSession()
                .dataTaskWithRequest(request) {
                    (data, response, error) -> Void in
                    if (error != nil) {
                        callback(NSDictionary())
                    } else {
                        var e: NSError?
                        var results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &e) as NSDictionary
                        if (e != nil) {
                            callback(NSDictionary())
                        } else {
                            callback(results)
                        }
                    }
            }
        
            task.resume()
    }
}
