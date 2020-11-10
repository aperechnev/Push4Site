//
//  AddSubscriberResponse.swift
//  
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import Foundation

internal struct AddSubscriberResponse: Decodable {
    let success: Bool
    let errorReason: String?
    let subscriberId: Int
}
