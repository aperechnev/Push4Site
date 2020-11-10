//
//  SegmentationEventResponse.swift
//  
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import Foundation

internal struct SegmentationEventResponse: Decodable {
    let success: Bool
    let errorReason: String?
}
