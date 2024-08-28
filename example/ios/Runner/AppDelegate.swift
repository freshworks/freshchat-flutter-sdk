import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Below code is implementation for user interaction listener support
    // FreshchatSdkPluginWindow needs to be initialised in the target application's app delegate for the user interaction listener to work
    // @property (nonatomic, strong) FreshchatSdkPluginWindow *window; should be added in the header file as well
    let viewController = UIApplication.shared.windows.first!.rootViewController as! UIViewController
    window = FreshchatSdkPluginWindow(frame: UIScreen.main.bounds)
    window.rootViewController = viewController
    
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    } else {
        // Fallback on earlier versions
    }
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            print("grant: \(granted)")
        }
    } else {
        // Fallback on earlier versions
    }
            UIApplication.shared.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let freshchatSdkPlugin = FreshchatSdkPlugin()
        print("Device Token \(deviceToken)")
        print("Device token is set")
        freshchatSdkPlugin.setPushRegistrationToken(deviceToken)
    }
    //@available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
            willPresent: UNNotification,
            withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        let freshchatSdkPlugin = FreshchatSdkPlugin()
    if freshchatSdkPlugin.isFreshchatNotification(willPresent.request.content.userInfo) {
        freshchatSdkPlugin.handlePushNotification(willPresent.request.content.userInfo) //Handled for freshchat notifications
    } else {
        withCompletionHandler([.alert, .sound, .badge]) //For other notifications
         }
    }
    //@available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive: UNNotificationResponse,
                              withCompletionHandler: @escaping ()->()) {
        let freshchatSdkPlugin = FreshchatSdkPlugin()
    if freshchatSdkPlugin.isFreshchatNotification(didReceive.notification.request.content.userInfo) {
        freshchatSdkPlugin.handlePushNotification(didReceive.notification.request.content.userInfo) //Handled for freshchat notifications
           withCompletionHandler()
    } else {
           withCompletionHandler() //For other notifications
        }
    }
}
