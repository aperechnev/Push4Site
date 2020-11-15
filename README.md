# Push4Site

Push4Site is the official iOS framework that provides access to Push4Site.com API.

## Installation

Push4Site is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Push4Site'
```

## Initialization

To initialize Push4Site SDK, you can follow the steps described in example below:

```Swift
// AppDelegate.swift

// ...
import Push4Site // First, import Push4Site module

// ...

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  // Ininitialize SDK with token, which can be obtained in Push4Site.com control panel.
  Push4Site.shared.configure(with: "dacd7f46202c11eba814309c23d3543b",
                             launchOptions: launchOptions)
  return true
}

// ...
```

Then subscribe for remote notifications by calling the appropriate method in any place, where you want end-user to be asked for permission to subscribe for notifications:

```Swift
Push4Site.shared.subscribeForNotifications()
```

This is all what you need to start using Push4Site SDK.

## Customizing notification appearence

If you need to customize remote notifications (e.g. to show an image), you also need to install Push4Site Notification Helper:

```ruby
pod 'Push4Site-UN'
```

Then create a new target in your project with type of `Notification Service Extension`. After target was created, open it's start point in `NotificationService.swift` file and pass the notification request to Push4Site SDK:

```Swift
override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    NotificationServiceHelper.shared.process(request: request,
                                             contentHandler: contentHandler)
}
```

Now your app is ready to show images in remote notifications.

## Sending custom events

To send custom event, just call the appropriate SDK method:

```Swift
let eventId = "my_custom_event"
Push4Site.shared.logEvent(with: eventId)
```

## Example

An example application, which shows how to work with Push4Site SDK, could be found in SDK's GitHub repository.

## License

Push4Site is available under the MIT license. See the LICENSE file for more info.
