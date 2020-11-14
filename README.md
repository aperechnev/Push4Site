# Push4Site

Push4Site is the official iOS framework that provides access to Push4Site.com API.

## Installation

Push4Site is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Push4Site'
```

If you need to customize remote notifications (e.g. to show an image arriving in notification), you also need to install Push4Site Notification Helper:

```ruby
pod 'Push4Site-UN'
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

Then subscribe for remote notifications by calling the appropriate method in any place, where you want end-user to be asked to permission to subscribe for notifications:

```Swift
Push4Site.shared.subscribeForNotifications()
```

## License

Push4Site is available under the MIT license. See the LICENSE file for more info.
