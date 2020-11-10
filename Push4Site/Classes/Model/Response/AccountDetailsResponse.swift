//
//  AccountDetailsResponse.swift
//  
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import Foundation

internal struct AccountDetailsResponse: Decodable {
    let success: Bool
    let errorReason: String?
}
