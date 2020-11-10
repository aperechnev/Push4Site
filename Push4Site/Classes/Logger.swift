//
//  Logger.swift
//  
//
//  Created by Alexander Perechnev on 06.11.2020.
//

import Moya
import RxSwift

public class Logger {
    
    private let disposeBag = DisposeBag()
    private let provider: MoyaProvider<PayloadService>
    
    init(provider: MoyaProvider<PayloadService>) {
        self.provider = provider
    }
    
    func logNotificationOpening(id notificationId: String) {
        let subscriberId = "\(PersistentStore().subscriberId)"
        
        let target: PayloadService = .notificationClicked(
            subscriberId: subscriberId,
            notificationId: notificationId
        )
        
        self.provider.rx
            .request(target)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
}
