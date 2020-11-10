//
//  PersistentStore.swift
//  Push4Site
//
//  Created by Alexander Perechnev on 09.11.2020.
//

import Foundation

internal class PersistentStore {
    
    private let subscriberIdKey = "push4site_subscriber_id"
    
    var subscriberId: Int {
        get {
            return UserDefaults.standard.integer(forKey: self.subscriberIdKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: self.subscriberIdKey)
        }
    }
    
}
