//
//  RMSupportManager.swift
//  ZendeskiOS
//
//  Created by Basawaraj on 23/02/16.
//  Copyright © 2016 Cuelogic. All rights reserved.
//

import UIKit

//Client
let ZDCategoryID    = "200920903"

//Zimplistic Dev Account
let ZDApplicationID = "bc0df7157f82b6a7452b44250c8b4be6609b39e341aa63f4"
let ZDUrl           = "https://rotimatic1444384919.zendesk.com"
let ZDClientID      = "mobile_sdk_client_beec1c992b90e9228d61"

//Test Account
//let ZDApplicationID = "df621aa520a840f2b9ec52369921496fc6208ace8da0d032"
//let ZDUrl           = "https://mesupport.zendesk.com"
//let ZDClientID      = "mobile_sdk_client_25b164921709c0ad70b0"

let UserName = "Basawaraj Hiremath"
let UserEmail = "basawaraj.hiremath@cuelogic.co.in"

//let UserName = "Rishi Israni"
//let UserEmail = "rishi@zimplistic.com"

class RMSupportManager: NSObject {

    static var sharedInstance = RMSupportManager()
    
    //MARK: Login and InitialConfiguration
    func configureZD(firstName: String?, email: String?) {
        
        //Anonymous Login
        anonymousZDLogin(firstName, email: email)
        
        //Initial Zendesk Config
        ZDKConfig.instance().initializeWithAppId(ZDApplicationID, zendeskUrl: ZDUrl, clientId: ZDClientID, onSuccess: { () -> Void in
            NSLog("Config found, Zendesk SDK is ready");
            }) { (error) -> Void in
                NSLog("Config could not be fetched for Zendesk SDK.");
        }
        
    }
    
    
    func configureZendesk() {
        
        //Config Zendesk
        configureZD(UserName, email: UserEmail)
        
    }
    
    
    func anonymousZDLogin(firstName: String?, email: String?) {
        
        let identity: ZDKAnonymousIdentity = ZDKAnonymousIdentity()
        
        identity.name = firstName
        identity.email = email
        identity.externalId = email
        
        ZDKConfig.instance().userIdentity = identity
        
    }

    
}
