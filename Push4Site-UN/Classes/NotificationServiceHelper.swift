//
//  NotificationServiceHelper.swift
//  Push4Site-UN
//
//  Created by Alexander Perechnev on 14.11.2020.
//

import UserNotifications
import Alamofire

public class NotificationServiceHelper {
    
    public static let shared = NotificationServiceHelper()
    
    /**
     Process user notification request to show images in remote notifications.
     - Parameters:
        - request: Request passed to notification service.
        - contentHandler: Callback passed to notification service.
     */
    public func process(
        request: UNNotificationRequest,
        contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
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
            
            contentHandler(bestAttemptContent)
        }
    }
    
}
