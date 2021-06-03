# SnapKit-LoginKit
This example will show how to use snapchat's LoginKit with swiftui.

An API that changed in IOS 14 was how you handle url's as you see below this is the old way of doing it
```swift
import SCSDKLoginKit

func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if SCSDKLoginClient.application(app, open: url, options: options) {
      return true
    }
}
```
While the new of doing things is this wich as you can see does not pass a `UIApplication` only a url as you can see below.
```swift
ConentView()
	.onOpenURL(perform: { url in
		print(ulr)
	})
```
So you need to pass it `UIApplication.shared` which does the trick.
```swift
ConentView()
	.onOpenURL(perform: { url in
		if SCSDKLoginClient.application(UIApplication.shared, open: url, options: nil) {
			print("Nice, snapchat can read your url")                      
		}
	})
```
