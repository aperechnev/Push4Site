//
//  AppDelegateImplementation.swift
//  Push4Site
//
//  Created by Alexander Perechnev on 08.11.2020.
//

import UIKit

internal protocol AppDelegateImplementationDelegate: class {
    func didObtain(deviceToken: Data)
}

internal class AppDelegateImplementation: NSObject {
    
    static let shared = AppDelegateImplementation()
    
    private override init() {
        super.init()
    }
    
    weak var delegate: AppDelegateImplementationDelegate?
    
    func swizzle() {
        self.swizzle(
            originalSelector: #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:)),
            swizzledSelector: #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        )
    }
    
    // MARK: Application delegate
    
    @objc func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        AppDelegateImplementation.shared.delegate?.didObtain(deviceToken: deviceToken)
        self.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    // MARK: Helper methods
    
    private func swizzle(
        originalSelector: Selector,
        swizzledSelector: Selector
    ) {
        let appDelegate = UIApplication.shared.delegate
        let appDelegateClass = object_getClass(appDelegate)

        guard let swizzledMethod = class_getInstanceMethod(
            AppDelegateImplementation.self, swizzledSelector
        ) else {
            fatalError("No implementation found for selector: \(swizzledSelector)")
        }

        if let originalMethod = class_getInstanceMethod(
            appDelegateClass, originalSelector
        ) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        } else {
            class_addMethod(appDelegateClass,
                            swizzledSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod))
        }
    }
    
}
