#  Pureprofile SDK

## Overview

Pureprofile is a survey platform that delivers surveys through the web and mobile apps. The Pureprofile iOS SDK is an easy to use library for developers who want to integrate Purerprofile's surveying platform into their iOS apps.  

## Project setup

### Prerequisites
In order to use the framework in your app you must have Xcode 11.0 with Swift 5.1 or later installed on your system. For the latest versions of Xcode, please visit [Apple’s iOS Dev Center](https://developer.apple.com/download/).

### Run time requirements

The minimum iOS version supported by the SDK is iOS 10.0.

## Installation method

You can get the Pureprofile SDK either via CocoaPods or by manually installing it in your Xcode project.

### CocoaPods

Open a command prompt in the Xcode project root directory (where the ‘.xcodeproj’ file is located).

If you do not yet have a Podfile for your project, run the following command to create an empty Podfile:

```
$ pod init
```

In a text editor, open the Podfile and add the following library name:

```
pod 'Pureprofile'
```

At the command prompt, run the following command to install the Pureprofile pod:

```
$ pod install
```

### Manual Integration

[Download](https://devtools.pureprofile.com/surveys/ios/latest/PureprofileSDK.zip) the latest Pureprofile SDK, extract the zip and follow the instructions below to manually integrate the SDK to your Xcode project.

1) Add Purerpofile SDK in Xcode

Drag and drop the PureprofileSDK.framework bundle in Xcode's document outline pane (1) and check the __Copy items if needed__ checkbox in the window that appears next.
Select your project in the document outline, in the General tab, PureprofileSDK.framework will be listed in the *Frameworks, Libraries and Embedded Content* section (2) and from there select __Embed & Sign__ as shown in the screenshot below. 

![alt text](https://devtools.pureprofile.com/surveys/ios/assets/Xcode_embedded_binaries_screenshot.jpg)

2) Always embed Swift standard library build setting (not needed if project already contains Swift code)

For projects with Objective-C only code, you have to set the 'Always embed Swift standard library' setting to yes in you project's Build Settings.

3) (Optional) Add the custom script in the build phases 

Add a new Run Script phase in your target’s Build Phases. Make sure this Run Script phase is below the Embed Frameworks build phase (You can drag and drop build phases to rearrange them).

Paste the following line in this Run Script Phase’s script text field:

```
bash "$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH/PureprofileSDK.framework/strip-frameworks.sh"
```

This script works around the [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries that contain bitcode. It also copies the frameworks’ .bcsymbolmap files into your target’s .xcarchive. These .bcsymbolmap files are needed if you want to include app symbols in order for your application to receive symbolicated crash logs from Apple when you upload it to the App Store.  

![alt text](https://devtools.pureprofile.com/surveys/ios/assets/Xcode_run_script_phase_screenshot.png)

4) Installation complete!

You are now ready to use the Pureprofile SDK and allow the users of your app to take Pureprofile surveys and earn rewards! Learn how below in our Quick Start guide.

## Quick start guide

### Login step

The first step before accessing the Pureprofile SDK is to obtain a login token from Pureprofile. You can do that by calling Pureprofile's [login API]("https://pp-auth-api.pureprofile.com/api/v1/panel/login") where you have to pass the following parameters in the POST call:

| Property name | Type          | Mandatory | Description
|---------------|---------------|:---------:|-------------
| panelKey      | String(UUID)  | Yes       | key which identifies partner or app and obtained by Pureprofile
| panelSecret   | String(UUID)  | Yes       | secret key assigned to partner
| userKey       | String        | Yes       | unique identifier of each user (see below for more)
| email         | String(Email) |           | email that can be used to match user

Response body:

| Property name | Type          | Description
|---------------|---------------|-------------
| ppToken       | String(UUID)  | Token that is passed to SDK so it can communicate with Pureprofile's servers

The values of  `panelKey` and `panelSecret` are provided by Pureprofile and are used to identify you as Pureprofile's partner. [Get in touch with us](mailto:product@pureprofile.com) to find out how to obtain the panel keys.

The `userKey` is used for uniquely identifying each one of your users. It is recommended that a UUID is used as `userKey` value and that this UUID never changes so that we can always identify your users in our systems in order to offer them better targeted surveys with maximum yield. There is no restriction though as to the type of user key that is used which means that your user's email or phone number or any other identifier is also accepted. Beware though that in this case if the user identifier ever changes, for example when your user changes his/her email, the next time the user with the changed identifier is logged in to Pureprofile, a new Pureprofile user will be created which means that all targeting information we hold for the said user will no longer be usable and will have to be recreated. The `email` key is optional and can be used to match a `userKey` with an email.

For testing and evaluation purposes Pureprofile provides a public partner account which can be used for running the sample app or for integrating the SDK with your app for evaluation purposes. A full example of how to log in a user, as well as the public partner keys can be found in the source code of the sample app. Bare in mind though that storing sensitive data (such as the panel key and secret) in the source files is not considered good practice and we therefore strongly suggest to employ a secure, server to server communication for obtaining the ppToken from Pureprofile. In this case the login service is called from your server after the authenticity of the client has been verified. See the diagram below for a depiction on how to login via an intermediate secure service.

![alt text](https://devtools.pureprofile.com/surveys/ios/assets/server2server_login.png)

#### Membership limit reached

As part of the login process it is possible to encounter the 'membership limit reached' error case which is triggered when the number of your users that have already used at least once the SDK has reached the limit that Pureprofile can accept at the time. The error case is signified with HTTP error code 403 and the body of the response contains error code _panel_membership_limit_reached_ as it can be seen in the example below. An example of how to handle the error in your application can be found in the source code of the sample app. The membership limit is configurable and when you get in touch with Pureprofile you can discuss and set it according to your membership requirements.
```
{
  "statusCode": 403,
  "error": "Forbidden",
  "message": "We're unable to register you for the panel at this time as the limit of panel members has been reached.",
  "data": {
    "code": "panel_membership_limit_reached"
  }
}
```

### Integrate SDK in your app

Having obtained a user token it's then really easy to enter in Pureprofile's surveying environment. All you need is to create a `Pureprofile` object and then present it from any UIViewController:

Swift example:
```swift
import PureprofileSDK

Pureprofile().open(fromViewController: self, loginToken: "pureprofile-login-token") { payment in
    print("Received payment of \(payment.value) with payment uuid: \(payment.uuid)")
}
```

Objective-C example:
```objectivec
@import PureprofileSDK;
#import <PureprofileSDK/PureprofileSDK-Swift.h>

[[Pureprofile new] openFromViewController:self loginToken:@"token" paymentHandler:^(PureprofilePayment * _Nonnull payment) {
    NSLog(@"Received payment of %f with payment uuid %@", payment.value, payment.uuid);
}];
```

The payment handler is used for passing back payment info whenever a user completes a survey with a reward. The PureprofilePayment class contains information about the payment where value is the amount awarded to the user for completing a survey:
```swift
open class PureprofilePayment: NSObject {
    public let value: Double
    public let uuid: String
    public let createdAt: Date
}
```

The transactions API can also be used for querying Pureprofile about a transaction. The payment uuid (as returned in `PureprofilePayment`) will have to be passed as a parameter to the end-point. Values `instanceUrl` and `instanceCode` are returned from the login API. Please see the sample app [code](https://github.com/pureprofile/pureprofile-sdk-ios/blob/master/SdkSampleApp/ViewController.swift#L45) for more.
```
GET https://<instanceUrl>/api/v1/<instanceCode>/transactions/<payment-uuid>

HTTP/1.1 200 OK

{
    "status": "ok",
    "data": {
        "uuid": "payment-uuid",
        "value": 1.05,
        "createdAt": "2018-11-24T23:33:36+11:00",
        "campaignUuid": "campaign-uuid"
    },
    "ppToken": "pureprofile-token"
}
```

### Count of available surveys
In order to obtain the total number of all and paid surveys at the time of the call you can use:  
```swift
public func countOfAvailableSurveys(loginToken: String, handler: @escaping (_ allSurveys: Int, _ paidSurveys: Int) -> Void)
```
You have to pass the login token obtained at the login step detailed above and through the callback you will receive two integers, one for all available surveys and one for the count of paid surveys.

### Landscape support
Some surveys are better displayed in landscape mode so from version 1.4.0 landscape support has been added for the surveys that require it. If your app already works in landscape there's nothing you need to do, landscape will automatically work for the SDK too. If it doesn't, adding the code below, will add landscape support in your app but specifically for the Pureprofile SDK. Meaning that landscape will be enabled only when the SDK view controllers that can handle orientation changes will be in foreground. You don't have to take any other consideration for handling orientation changes in any of your view controllers as they will still work only in portrait mode.

In your AppDelegate add the following code:    
```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    if let rootViewController = window?.rootViewController,
        let topViewController = topViewController(with: rootViewController),
        let rotableViewController = topViewController as? PureprofileSDK.RotatableViewController {
        return rotableViewController.supportedOrientations
    }

    return .portrait
}

private func topViewController(with rootViewController: UIViewController) -> UIViewController? {
    if let tabVC = rootViewController as? UITabBarController, let selectedVC = tabVC.selectedViewController {
        return topViewController(with: selectedVC)
    } else if let navVC = rootViewController as? UINavigationController, let visibleVC = navVC.visibleViewController {
        return topViewController(with: visibleVC)
    } else if let presented = rootViewController.presentedViewController {
        return topViewController(with: presented)
    }
    return rootViewController
}
```

```objectivec
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (window && window.rootViewController) {
        UIViewController *topVC = [self _topViewControllerWithRootViewController:window.rootViewController];
        if (topVC && [topVC conformsToProtocol:@protocol(RotatableViewController)]) {
            id<RotatableViewController> rotatableVC = (id<RotatableViewController>)topVC;
            return rotatableVC.supportedOrientations;
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)_topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootViewController;
        if (tabVC.selectedViewController) {
            return [self _topViewControllerWithRootViewController:tabVC.selectedViewController];
        }
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)rootViewController;
        if (navVC.visibleViewController) {
            return [self _topViewControllerWithRootViewController:navVC.visibleViewController];
        }
    } else if (rootViewController.presentedViewController) {
        return [self _topViewControllerWithRootViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}
```
