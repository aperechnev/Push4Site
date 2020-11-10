//
//  GenericService.swift
//
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import Moya

enum GenericService: TargetType {
    
    case getAccountDetails(
            token: String
         )
    case addSubscriber(
            token: String,
            subscriptionToken: String,
            device: String,
            osVersion: String
         )
    case segmentationEvent(
            token: String,
            eventName: String,
            subscriberId: String
         )
    
    var baseURL: URL {
        return URL(string: "https://push4site.com/IosInterface/")!
    }
    
    var path: String {
        switch self {
        case .getAccountDetails:
            return "GetAccountDetails"
        case .addSubscriber:
            return "AddSubscriber"
        case .segmentationEvent:
            return "SegmentationEvent"
        }
    }
    
    var method: Moya.Method {
        .post
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case let .getAccountDetails(token):
            return self.request(
                with: [
                    "token": token
                ]
            )
        case let .addSubscriber(token, subscriptionToken, device, osVersion):
            return self.request(
                with: [
                    "token": token,
                    "subscriptionToken": subscriptionToken,
                    "device": device,
                    "osVersion": osVersion,
                ]
            )
        case let .segmentationEvent(token, eventName, subscriberId):
            return self.request(
                with: [
                    "token": token,
                    "eventName": eventName,
                    "subscriberId": subscriberId,
                ]
            )
        }
    }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
    
    private func request(with parameters: [String:Any]) -> Task {
        let encoding = JSONEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
