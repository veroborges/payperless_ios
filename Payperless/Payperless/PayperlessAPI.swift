//
//  PayperlessAPI.swift
//  Payperless
//
//  Created by Veronica Borges on 11/1/14.
//  Copyright (c) 2014 Veronica Borges. All rights reserved.
//

import Foundation

class PayperlessAPI: NSObject {

    var host = "http://localhost:3000"
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
    func issueStoreCard(amount:Float, merchantID:Float, userID:Int, callback:(NSDictionary) -> Void){
        let params = "merchant_id=\(merchantID)&amount=\(amount)&user_id=\(userID)"
        HTTPPostJSON("/api/issue_store_card", dataString: params, callback)
    }

    /*****
    # GET /api/check_card_balance
    # params:
    # 	cardID
    # returns:
    # 	balance
    ****/
    func checkCardBalance(cardID:String, callback:(NSDictionary) -> Void) {
        let params = "card_id=\(cardID)"
        HTTPGetJSON("/api/check_card_balance", dataString: params, callback)
        
    }

    
    /*****
    # GET /api/get_all_transactions
    # params:
    # 	userID
    # returns:
    # 	array of transactions
    ****/
    func getAllTransactions(userID:String, callback:(NSDictionary) -> Void) {
        let params = "user_id=\(userID)"
        HTTPGetJSON("/api/get_all_transactions", dataString: params, callback)
    }
    
    
    
    
    /** HELPER FUNCTIONS FOR POST/GET ***/
    
    func HTTPPostJSON(urlPath: String,dataString:String, callback: (NSDictionary) -> Void) {
            var request = NSMutableURLRequest(URL: NSURL(string: "\(host)\(urlPath)")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.HTTPBody = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            HTTPsendRequest(request, callback)
    }
    
    
    func HTTPGetJSON(urlPath: String, dataString:String, callback: (NSDictionary) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(host)\(urlPath)?\(dataString)")!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        HTTPsendRequest(request, callback)
    }
    
    func HTTPsendRequest(request: NSMutableURLRequest,callback: (NSDictionary) -> Void) {
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