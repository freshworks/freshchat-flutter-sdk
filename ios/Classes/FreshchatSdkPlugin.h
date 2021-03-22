#import <Flutter/Flutter.h>

@interface FreshchatSdkPlugin : NSObject<FlutterPlugin>
-(void)handlePushNotification:(NSDictionary *) pushPayload;
-(BOOL)isFreshchatNotification:(NSDictionary *) pushPayload;
-(void)setPushRegistrationToken:(NSData *) deviceToken;
@end
