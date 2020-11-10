//
//  PayloadService.swift
//  
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import Moya

enum PayloadService: TargetType {
    
    case notificationReceived(
            subscriberId: String,
            notificationId: String
         )
    case notificationClicked(
            subscriberId: String,
            notificationId: String
         )
    
    var baseURL: URL {
        URL(string: "https://pushpayload.push4site.com/Ios/")!
    }
    
    var path: String {
        switch self {
        case .notificationReceived:
            return "NotificationReceived"
        case .notificationClicked:
            return "NotificationClicked"
        }
    }
    
    var method: Moya.Method {
        .get
    }

    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case let .notificationReceived(subscriberId, notificationId),
             let .notificationClicked(subscriberId, notificationId):
            return self.request(
                with: [
                    "subscriberId": subscriberId,
                    "notificationId": notificationId,
                ]
            )
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    private func request(with parameters: [String:Any]) -> Task {
        let encoding = URLEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
