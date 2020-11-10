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

/**
 The main class that provides API to end-users.
 */
public class Push4Site: NSObject {
    
    private let disposeBag = DisposeBag()
    private let genericProvider: MoyaProvider<GenericService>
    private let persistentStore = PersistentStore()
    private let logger: Logger
    private let appDelegate = AppDelegateImplementation.shared
    
    private var token: String?
    private var subscriberId: String?
    
    internal var deviceToken: Data? {
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
        - launchOptions: Launch options passed to application's `application(_:didFinishLaunchingWithOptions:)` method.
     */
    public func configure(
        with token: String,
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) {
        self.token = token
        
        self.genericProvider.rx
            .request(.getAccountDetails(token: token))
            .map(AccountDetailsResponse.self)
            .subscribe(onSuccess: { response in
                if response.success {
                    print("Push4Site successfully initialized.")
                } else {
                    var message = "Failed to initialize Push4Site"
                    if let error = response.errorReason {
                        message += ": \(error)"
                    } else {
                        message += "."
                    }
                    print(message)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    /**
     Ask user for access to subscribe for remote notifications and subscribe to remote notifications in case of user's confirmation.
     */
    public func subscribeForNotifications() {
        self.appDelegate.delegate = self
        self.appDelegate.swizzle()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
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
                if response.success {
                    self.persistentStore.subscriberId = response.subscriberId
                } else {
                    print("Failed to update device token: \(response.errorReason ?? "unknown error")")
                }
            }, onError: { error in
                print("Failed to update device token: \(error.localizedDescription)")
            })
            .disposed(by: self.disposeBag)
    }
    
    /**
     Log custom event with given identifier.
     - Parameters:
        - id: Event identifier.
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
            .subscribe(onSuccess: { response in
                if response.success == false {
                    print("Failed to log custom event: \(response.errorReason ?? "unknown error")")
                }
            }, onError: { error in
                print("Failed to log custom event: \(error.localizedDescription)")
            })
            .disposed(by: self.disposeBag)
    }
    
}

extension Push4Site: AppDelegateImplementationDelegate {
    
    internal func didObtain(deviceToken: Data) {
        self.deviceToken = deviceToken
    }
    
}

extension Push4Site: UNUserNotificationCenterDelegate {
    
    internal func userNotificationCenter(
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
