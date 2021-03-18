#import <Flutter/Flutter.h>

#if __has_include("FreshchatSDK.h")
#import "FreshchatSDK.h"
#else
#import "FreshchatSDK/FreshchatSDK.h"
#endif

@interface FreshchatSdkPlugin : NSObject<FlutterPlugin>
-(void)handlePushNotification:(NSDictionary *) pushPayload;
-(BOOL)isFreshchatNotification:(NSDictionary *) pushPayload;
-(void)setPushRegistrationToken:(NSData *) deviceToken;
@end
