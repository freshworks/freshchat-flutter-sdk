#import <Flutter/Flutter.h>
#define FRESHCHAT_USER_INTERACTED @"com.freshchat.consumer.sdk.flutter.actions.UserInteraction"
#define FRESHCHAT_ACTION_JWT @"com.freshchat.consumer.sdk.flutter.actions.jwt"

@interface FreshchatSdkPlugin : NSObject<FlutterPlugin>
-(void)handlePushNotification:(NSDictionary *) pushPayload;
-(BOOL)isFreshchatNotification:(NSDictionary *) pushPayload;
-(void)setPushRegistrationToken:(NSData *) deviceToken;
@end

@interface FreshchatSdkPluginWindow : UIWindow
@end

