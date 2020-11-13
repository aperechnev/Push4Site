//
//  NotificationService.swift
//  NotificationServiceExample
//
//  Created by Alexander Perechnev on 13.11.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UserNotifications
import Alamofire

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        guard let urlString = bestAttemptContent.userInfo["attachment"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        guard let url = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            let temporaryURL = FileManager.default.temporaryDirectory
            let fileURL = temporaryURL.appendingPathComponent(url.lastPathComponent)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination).response { response in
            if response.error == nil, let imageURL = response.fileURL {
                if let attachment = try? UNNotificationAttachment(
                    identifier: "image", url: imageURL, options: nil
                ) {
                    bestAttemptContent.attachments = [attachment]
                }
            }
            
            self.contentHandler!(self.bestAttemptContent!)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
