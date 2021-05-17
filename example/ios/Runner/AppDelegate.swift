import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            print("grant: \(granted)")
        }
        UIApplication.shared.registerForRemoteNotifications()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let freshchatSdkPlugin = FreshchatSdkPlugin()
    print("Device Token \(deviceToken)")
    print("Device token is set")
    freshchatSdkPlugin.setPushRegistrationToken(deviceToken)
}

func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    let freshchatSdkPlugin = FreshchatSdkPlugin()
    if freshchatSdkPlugin.isFreshchatNotification(userInfo){
        NSLog("is Freshchat Notification")
        freshchatSdkPlugin.handlePushNotification(userInfo)
    }else{
        NSLog("Not Freshchat Notification")
    }
    completionHandler(.newData)
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for notifications: \(error.localizedDescription)")
}

