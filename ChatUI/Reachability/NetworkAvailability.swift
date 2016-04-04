//
//  NetworkAvailability.swift
//  RotimaticMobile
//
//  Created by Basawaraj on 20/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit

class NetworkAvailability: NSObject {
    
    let reachability = Reachability.reachabilityForInternetConnection()
    var isNetWorkAvailable : Bool = false
    
    static let sharedInstance = NetworkAvailability()
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        reachability?.startNotifier()
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            isNetWorkAvailable = true
        } else {
            isNetWorkAvailable = false
        }
    }
    
     func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()!
        let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
        return networkStatus != 0
    }

    
}
