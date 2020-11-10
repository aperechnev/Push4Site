//
//  Push4Site.swift
//  
//
//  Created by Alexander Perechnev on 05.11.2020.
//

import UIKit
import UserNotifications
import RxSwift
import Moya

public protocol Push4SiteDelegate: class {
    func didFailToUpdateDeviceToken(with error: Error)
}

public class Push4Site: NSObject {
    
    private let disposeBag = DisposeBag()
    private let genericProvider: MoyaProvider<GenericService>
    private let persistentStore = PersistentStore()
    private let logger: Logger
    private let appDelegate = AppDelegateImplementation.shared
    
    private var token: String?
    private var subscriberId: String?
    
    public var delegate: Push4SiteDelegate?
    public var deviceToken: Data? {
        didSet {
            if let deviceToken = self.deviceToken {
                self.update(with: deviceToken)
            }
        }
    }
    
    private static func makeLoggerPlugin() -> PluginType {
        let configuration = NetworkLoggerPlugin.Configuration(logOptions: [
            .requestBody,
            .requestHeaders,
            .requestMethod,
            .successResponseBody,
            .errorResponseBody
        ])
        return NetworkLoggerPlugin(configuration: configuration)
    }
    
    /**
     All methods provided by Push4Site library should be accessed via this shared instance.
     */
    public static let shared = Push4Site()
    
    private override init() {
        let plugins: [PluginType] = [Push4Site.makeLoggerPlugin()]
        self.genericProvider = MoyaProvider<GenericService>(plugins: plugins)
        
        let payloadProvider = MoyaProvider<PayloadService>(plugins: plugins)
        self.logger = Logger(provider: payloadProvider)
        
        super.init()
    }
    
    /**
     Initialize the library with given token and launch options.
     
     - Parameters:
        - token: A token that you can obtain in admin panel on the website.
        - launchOptions: -
        - completion: -
     */
    public func configure(
        with token: String,
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
        completion: @escaping (Bool, String?) -> ()
    ) {
        self.genericProvider.rx
            .request(.getAccountDetails(token: token))
            .map(AccountDetailsResponse.self)
            .subscribe(onSuccess: { response in
                if response.success {
                    self.token = token
                }
                completion(response.success, response.errorReason)
            }, onError: { error in
                completion(false, nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    /**
     Not documented.
     */
    public func subscribeForNotifications(
        completion: @escaping (Bool, Error?) -> ()
    ) {
        self.appDelegate.delegate = self
        self.appDelegate.swizzle()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
            completion(granted, error)
        }
    }
    
    private func update(with deviceToken: Data) {
        guard let token = self.token else {
            fatalError(
                "Trying to subscribe for notifications without setting the Push4Site token."
            )
        }
        
        let deviceTokenString = deviceToken
            .map { String(format: "%02.2hhx", $0) }
            .joined()
        
        let device = UIDevice.current
        let deviceModel = device.model
        let osVersion = device.systemName + " " + device.systemVersion
        
        let target: GenericService = .addSubscriber(
            token: token,
            subscriptionToken: deviceTokenString,
            device: deviceModel,
            osVersion: osVersion
        )
        
        self.genericProvider.rx
            .request(target)
            .map(AddSubscriberResponse.self)
            .subscribe(onSuccess: { response in
                self.persistentStore.subscriberId = response.subscriberId
            }, onError: { error in
                self.delegate?.didFailToUpdateDeviceToken(with: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    /**
     Not documented.
     */
    public func logEvent(with id: String) {
        guard let token = self.token else {
            fatalError("Trying to send event with no token.")
        }
        guard let subscriberId = self.subscriberId else {
            fatalError("Trying to log event with no subscriber id.")
        }
        
        self.genericProvider.rx
            .request(.segmentationEvent(token: token, eventName: id, subscriberId: subscriberId))
            .map(SegmentationEventResponse.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: self.disposeBag)
    }
    
}

extension Push4Site: AppDelegateImplementationDelegate {
    
    func didObtain(deviceToken: Data) {
        self.deviceToken = deviceToken
    }
    
}

extension Push4Site: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let notificationId = userInfo["notificationId"] as? String {
            self.logger.logNotificationOpening(id: notificationId)
        }
        
        if let delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate {
            delegate.userNotificationCenter?(center,
                                             didReceive: response,
                                             withCompletionHandler: completionHandler)
        }
        
        completionHandler()
    }
    
}
