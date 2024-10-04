#import "FreshchatSdkPlugin.h"
#if __has_include("FreshchatSDK.h")
#import "FreshchatSDK.h"
#else
#import "FreshchatSDK/FreshchatSDK.h"
#endif

@implementation FreshchatSdkPluginWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:FRESHCHAT_USER_INTERACTED object:self];
    return [super hitTest:point withEvent:event];
}
@end

@implementation FreshchatSdkPlugin

FlutterMethodChannel* channel;
FreshchatSdkPlugin* instance;
NSObject* freshchatEvent;
NSObject* restoreEvent;
NSObject* messageCountEvent;
NSObject* jwtRefreshEvent;
NSObject* userInteractionEvent;
NSNotificationCenter *center;
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
               methodChannelWithName:@"freshchat_sdk"
               binaryMessenger:[registrar messenger]];
    instance = [[FreshchatSdkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    center = [NSNotificationCenter defaultCenter];
}


- (void)init:(FlutterMethodCall*)call{
    @try {
        FreshchatConfig *freshchatConfig = [[FreshchatConfig alloc]initWithAppID:(call.arguments[@"appId"]) andAppKey:(call.arguments[@"appKey"])];
        freshchatConfig.domain = call.arguments[@"domain"];
        freshchatConfig.responseExpectationVisible = [call.arguments[@"responseExpectationEnabled"]boolValue];
        freshchatConfig.teamMemberInfoVisible = [call.arguments[@"teamMemberInfoVisible"]boolValue];
        freshchatConfig.cameraCaptureEnabled = [call.arguments[@"cameraCaptureEnabled"]boolValue];
        freshchatConfig.gallerySelectionEnabled = [call.arguments[@"gallerySelectionEnabled"]boolValue];
        freshchatConfig.eventsUploadEnabled = [call.arguments[@"userEventsTrackingEnabled"]boolValue];
        freshchatConfig.errorLogsEnabled = [call.arguments[@"errorLogsEnabled"]boolValue];
        freshchatConfig.showNotificationBanner = [call.arguments[@"showNotificationBanneriOS"]boolValue];
        freshchatConfig.fileAttachmentEnabled = [call.arguments[@"fileSelectionEnabled"]boolValue];
        NSString* stringsBundle = call.arguments[@"stringsBundle"];
        NSString* themeName = call.arguments[@"themeName"];
        if(![themeName isEqual:[NSNull null]]) {
            freshchatConfig.themeName = themeName;
        }
        
        if(![stringsBundle isEqual:[NSNull null]]) {
            freshchatConfig.stringsBundle = stringsBundle;
        }
        [[Freshchat sharedInstance]initWithConfig:freshchatConfig];
    } @catch (NSException *exception) {
        NSLog(@"initialize SDK CRASH: %@ %@", exception.name, exception.reason);
    }
}


- (void)showConversations{
    UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [[Freshchat sharedInstance]showConversations:visibleVC];
}

-(void)showFAQs{
    UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [[Freshchat sharedInstance] showFAQs:visibleVC];
}

-(NSString*)getFreshchatUserId{
    NSString* alias = [[Freshchat sharedInstance] getFreshchatUserId];
    return alias;
}

-(void)resetUser{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Freshchat sharedInstance]resetUserWithCompletion:^{}];
    });
}

-(void)setUserProperties:(FlutterMethodCall *) call{
    @try {
        NSDictionary* args = call.arguments[@"propertyMap"];
        NSArray *keys = [args allKeys];
        if(keys.count == 0){
            NSLog(@"Please provide valid field in object to updateUserProperties");
        } else {
            NSArray *arrayOfKeys = [args allKeys];
            NSArray *arrayOfValues = [args allValues];
            NSString *key;
            NSString *value;
            for(int i=0; i<arrayOfKeys.count; i++) {
                key = [arrayOfKeys objectAtIndex:i];
                value = [arrayOfValues objectAtIndex:i];
                [[Freshchat sharedInstance] setUserPropertyforKey:key withValue:value];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error on set user properties: %@ %@", exception.name, exception.reason);
    }
}

-(void)setBotVariables:(FlutterMethodCall *) call{
    @try {
        NSDictionary* botVariables = call.arguments[@"botVariables"];
        NSDictionary* specificVariables = call.arguments[@"specificVariables"];
        if(botVariables.count == 0 && specificVariables.count == 0){
            NSLog(@"Please provide valid bot variables");
        } else {
            [[Freshchat sharedInstance] setBotVariables:botVariables withBotSpecificVariables: specificVariables];
        }
    } @catch (NSException *exception) {
        NSLog(@"Error on setBotVariables: %@ %@", exception.name, exception.reason);
    }
}

-(void)setUser:(FlutterMethodCall *) call{
    @try {
        FreshchatUser *user = [FreshchatUser sharedInstance];
        if(![call.arguments[@"firstName"] isEqual:[NSNull null]]){
            user.firstName = call.arguments[@"firstName"];
        }
        if(![call.arguments[@"lastName"] isEqual:[NSNull null]]){
            user.lastName = call.arguments[@"lastName"];
        }
        if(![call.arguments[@"email"] isEqual:[NSNull null]]){
            user.email = call.arguments[@"email"];
        }
        if(![call.arguments[@"phoneCountryCode"] isEqual:[NSNull null]]){
            user.phoneCountryCode = call.arguments[@"phoneCountryCode"];
        }
        if(![call.arguments[@"phoneNumber"] isEqual:[NSNull null]]){
            user.phoneNumber = call.arguments[@"phoneNumber"];
        }
        [[Freshchat sharedInstance] setUser:user];
    } @catch (NSException *exception) {
        NSLog(@"Error on set user details: %@ %@", exception.name, exception.reason);
    }
}

-(NSMutableDictionary*)getUser{
    FreshchatUser *user = [FreshchatUser sharedInstance];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:user.email forKey:@"email"];
    [dic setValue:user.firstName forKey:@"firstName"];
    [dic setValue:user.lastName forKey:@"lastName"];
    [dic setValue:user.phoneCountryCode forKey:@"phoneCountryCode"];
    [dic setValue:user.phoneNumber forKey:@"phone"];
    [dic setValue:user.externalID forKey:@"externalId"];
    [dic setValue:user.restoreID forKey:@"restoreId"];
    return dic;
}

-(void)showFAQsWithOptions:(FlutterMethodCall *) call{
    @try {
        FAQOptions *options = [FAQOptions new];
        NSMutableArray *faqTagsList = call.arguments[@"faqTags"];
        NSString *faqTitle =call.arguments[@"faqTitle"];
        NSMutableArray *contactusTagsList = call.arguments[@"contactUsTags"];
        NSString *contactUsTitle = call.arguments[@"contactUsTitle"];
        options.showContactUsOnFaqScreens = [call.arguments[@"showContactUsOnFaqScreens"]boolValue];
        options.showFaqCategoriesAsGrid = [call.arguments[@"showFaqCategoriesAsGrid"]boolValue];;
        options.showContactUsOnAppBar = [call.arguments[@"showContactUsOnAppBar"]boolValue];
        options.showContactUsOnFaqNotHelpful = [call.arguments[@"showContactUsOnFaqNotHelpful"]boolValue];
        NSString* filterType = call.arguments[@"faqFilterType"];
        if(![faqTagsList isEqual:[NSNull null]] && ![faqTitle isEqual:[NSNull null]]){
            if(![filterType isEqual:[NSNull null]] && [@"Category" isEqualToString:filterType]) {
                [options filterByTags:faqTagsList withTitle:faqTitle andType: CATEGORY];
            } else{
                [options filterByTags:call.arguments[@"faqTags"] withTitle:call.arguments[@"faqTitle"] andType: ARTICLE];
            }
        }
        if(![contactusTagsList isEqual:[NSNull null]] && ![contactUsTitle isEqual:[NSNull null]]){
            [options filterContactUsByTags:contactusTagsList withTitle:contactUsTitle];
        }
        UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [[Freshchat sharedInstance] showFAQs:visibleVC withOptions:options];
    } @catch (NSException *exception) {
        NSLog(@"Error on showing FAQs with tags: %@ %@", exception.name, exception.reason);
    }
}

-(void)showConversationsWithOptions:(FlutterMethodCall *) call{
    @try {
        ConversationOptions *options = [ConversationOptions new];
        NSArray *tags = call.arguments[@"tags"];
        NSString *filteredViewTitle =call.arguments[@"filteredViewTitle"];
        if([tags isEqual:[NSNull null]]){
            tags = @[@""];
        }
        if([filteredViewTitle isEqual:[NSNull null]]){
            filteredViewTitle = @"";
        }
        [options filterByTags:tags withTitle:filteredViewTitle];
        UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [[Freshchat sharedInstance] showConversations:visibleVC withOptions: options];
    } @catch (NSException *exception) {
        NSLog(@"Error on showing conversations with tags: %@ %@", exception.name, exception.reason);
    }
}

-(void)showConversationWithReferenceID:(FlutterMethodCall *) call {
    @try {
        NSString *conversationReferenceID = call.arguments[@"conversationReferenceID"];
        NSString *topicName = call.arguments[@"topicName"];
        UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [[Freshchat sharedInstance] showConversation:visibleVC withTopicName:topicName withConversationReferenceID:conversationReferenceID];
    } @catch (NSException *exception) {
        NSLog(@"Error on showing conversation with reference id: %@ %@", exception.name, exception.reason);
    }
}

-(void)sendMessage:(FlutterMethodCall *) call{
    @try {
        FreshchatMessage *userMessage = [[FreshchatMessage alloc] initWithMessage:call.arguments[@"message"] andTag:call.arguments[@"tag"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Freshchat sharedInstance] sendMessage:userMessage];
        });
    } @catch (NSException *exception) {
        NSLog(@"Error on send message: %@ %@", exception.name, exception.reason);
    }
}

-(void)trackEvent:(FlutterMethodCall *) call{
    @try {
        NSDictionary* properties = call.arguments[@"properties"];
        if([properties isEqual:[NSNull null]]){
            properties = @{};
        }
        [[Freshchat sharedInstance] trackEvent:call.arguments[@"eventName"] withProperties:properties];
    } @catch (NSException *exception) {
        NSLog(@"Error on tracking events: %@ %@", exception.name, exception.reason);
    }
}

-(void)getUnreadCountAsync:(FlutterResult) result{
    [[Freshchat sharedInstance] unreadCountWithCompletion:^(NSInteger unreadCount) {
        @try {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"STATUS_SUCCESS"  forKey:@"status"];
            [dic setValue:[NSNumber numberWithInteger:unreadCount] forKey:@"count"];
            result(dic);
        } @catch (NSException *exception) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"STATUS_ERROR"  forKey:@"status"];
            [dic setValue:[NSNumber numberWithInteger:unreadCount] forKey:@"count"];
            result(dic);
        }
    }];
}

-(void)getUnreadCountAsyncForTags:(FlutterMethodCall*)call result:(FlutterResult) result{
    NSArray *tags = call.arguments[@"tags"];
    [[Freshchat sharedInstance] unreadCountForTags:tags withCompletion:^(NSInteger unreadCount) {
        @try {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"STATUS_SUCCESS"  forKey:@"status"];
            [dic setValue:[NSNumber numberWithInteger:unreadCount] forKey:@"count"];
            result(dic);
        } @catch (NSException *exception) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"STATUS_ERROR"  forKey:@"status"];
            [dic setValue:[NSNumber numberWithInteger:unreadCount] forKey:@"count"];
            result(dic);
        }
    }];
}

-(void)setUserWithIdToken:(FlutterMethodCall *) call{
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Freshchat sharedInstance] setUserWithIdToken:call.arguments[@"token"]];
        });
    } @catch (NSException *exception) {
        NSLog(@"Error on set user with id token: %@ %@", exception.name, exception.reason);
    }
    
}

-(void)restoreUserWithJwt:(FlutterMethodCall *) call{
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Freshchat sharedInstance] restoreUserWithIdToken:call.arguments[@"token"]];
        });
    } @catch (NSException *exception) {
        NSLog(@"Error on restoring user with jwt token: %@ %@", exception.name, exception.reason);
    }
}

-(NSString *)getUserIdTokenStatus{
    NSString* idTokenStatus = [[Freshchat sharedInstance] getUserIdTokenStatus];
    return idTokenStatus;
}

-(void)identifyUser:(FlutterMethodCall *) call{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *restoreId =call.arguments[@"restoreId"];
            if([restoreId isEqual:[NSNull null]]){
                restoreId = @"";
            }
            [[Freshchat sharedInstance] identifyUserWithExternalID:call.arguments[@"externalId"] restoreID:restoreId];
        } @catch (NSException *exception) {
            NSLog(@"Error restoring user");       }
    });
}
-(void)setNotificationConfig{
    //Dummy method for android implementation since notificationConfig is not available in iOS
}

-(void)setPushRegistrationToken:(NSData *) deviceToken{
    [[Freshchat sharedInstance] setPushRegistrationToken:deviceToken];
}

-(BOOL)isFreshchatNotification:(NSDictionary *) pushPayload{
    return [[Freshchat sharedInstance]isFreshchatNotification:pushPayload];
}

-(void)handlePushNotification:(NSDictionary *) pushPayload{
    [[Freshchat sharedInstance]handleRemoteNotification:pushPayload andAppstate:[[UIApplication sharedApplication] applicationState]];
}

-(void)registerForEvent:(FlutterMethodCall *) call{
    NSString* eventName = call.arguments[@"eventName"];
    if([call.arguments[@"shouldRegister"]boolValue]){
        if([eventName isEqual:(@"FRESHCHAT_USER_RESTORE_ID_GENERATED")]){
            [instance registerForRestoreIdUpdates:YES];
        }else
        if([eventName isEqual:(@"FRESHCHAT_EVENTS")]){
            [instance registerForUserActions:YES];
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED")]){
            [instance registerForMessageCountUpdates:YES];
        }else
        if([eventName isEqual:(@"ACTION_OPEN_LINKS")]){
            [instance registerForOpeningLink:YES];
        }else
        if([eventName isEqual:(@"ACTION_LOCALE_CHANGED_BY_WEBVIEW")]){
            NSLog(@"ACTION_LOCALE_CHANGED_BY_WEBVIEW not supported in iOS");
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_NOTIFICATION_CLICK_LISTENER")]){
            NSLog(@"FRESHCHAT_ACTION_NOTIFICATION_CLICK_LISTENER not needed in flutter iOS");
        }else
        if([eventName isEqual:(@"FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES")]){
            [instance registerForJWTRefresh:YES];
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_USER_INTERACTION")]){
            [instance registerForUserInteraction:YES];
        }
    }
    else{
        if([eventName isEqual:(@"FRESHCHAT_USER_RESTORE_ID_GENERATED")]){
            [instance registerForRestoreIdUpdates:NO];
        }else
        if([eventName isEqual:(@"FRESHCHAT_EVENTS")]){
            [instance registerForUserActions:NO];
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED")]){
            [instance registerForMessageCountUpdates:NO];
        }else
        if([eventName isEqual:(@"ACTION_OPEN_LINKS")]){
            [instance registerForOpeningLink:NO];
        }else
        if([eventName isEqual:(@"ACTION_LOCALE_CHANGED_BY_WEBVIEW")]){
            NSLog(@"ACTION_LOCALE_CHANGED_BY_WEBVIEW not supported in iOS");
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_NOTIFICATION_CLICK_LISTENER")]){
            NSLog(@"FRESHCHAT_ACTION_NOTIFICATION_CLICK_LISTENER not needed in flutter iOS");
        }else
        if([eventName isEqual:(@"FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES")]){
            [instance registerForJWTRefresh:NO];
        }else
        if([eventName isEqual:(@"FRESHCHAT_ACTION_USER_INTERACTION")]){
            [instance registerForUserInteraction:NO];
        }
    }
}

-(void) registerForRestoreIdUpdates:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        restoreEvent = [center addObserverForName:FRESHCHAT_USER_RESTORE_ID_GENERATED object:nil queue:nil usingBlock:^(NSNotification *note) {
            [channel invokeMethod:@"FRESHCHAT_USER_RESTORE_ID_GENERATED"
                        arguments:@YES];
        }];
    } else {
        [center removeObserver:restoreEvent
                          name:FRESHCHAT_USER_RESTORE_ID_GENERATED object:nil];
    }
}

-(void)registerForUserActions:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        freshchatEvent = [center addObserverForName:FRESHCHAT_EVENTS object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary *eventName = (id)note.userInfo;
            if (eventName!=nil) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                FreshchatEvent *event = eventName[@"event"];
                NSString *eventName = [event getEventName];
                [dic setValue:eventName forKey:@"event_name"];
                if (event.properties) {
                    [dic setValue:event.properties forKey:@"properties"];
                }
                // Token status not exposed in iOS yet
                [channel invokeMethod:@"FRESHCHAT_EVENTS"
                            arguments:dic];
            }
        }];
    } else {
        [center removeObserver:freshchatEvent
                          name:FRESHCHAT_EVENTS object:nil];
    }
}

-(void)registerForMessageCountUpdates:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        messageCountEvent = [[NSNotificationCenter defaultCenter]addObserverForName:FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [channel invokeMethod:@"FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED"
                        arguments:@YES];
        }];
    }
    else {
        [center removeObserver:messageCountEvent
                          name:FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED object:nil];
    }
}

-(void)registerForOpeningLink:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        NSLog(@"registerForOpeningLink YES");
        [Freshchat sharedInstance].customLinkHandler = ^BOOL(NSURL * url) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        [dic setValue:url.description forKey:@"url"];
                        [channel invokeMethod:@"ACTION_OPEN_LINKS"
                                                        arguments:dic];
                        return YES;
        };
    } else {
        NSLog(@"registerForOpeningLink NO");
        [Freshchat sharedInstance].customLinkHandler = nil;
    }
}

-(void)registerForJWTRefresh:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        jwtRefreshEvent = [[NSNotificationCenter defaultCenter]addObserverForName:FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [channel invokeMethod:@"FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES"
                        arguments:@YES];
        }];
    } else {
        [center removeObserver:jwtRefreshEvent
                          name:FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES object:nil];
    }
}

-(void)registerForUserInteraction:(BOOL)shouldRegister
{
    if (shouldRegister == YES) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userInteracted:) name:FRESHCHAT_USER_INTERACTED object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FRESHCHAT_USER_INTERACTED object:nil];
    }
}

-(void) userInteracted:(NSNotification *) notification {
    [channel invokeMethod:@"FRESHCHAT_ACTION_USER_INTERACTION" arguments: nil];
}


- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)openFreshchatDeeplink:(FlutterMethodCall *) call{
    NSString* link = call.arguments[@"link"];
    UIViewController *visibleVC = [instance topMostController];
    [[Freshchat sharedInstance] openFreshchatDeeplink:link viewController:visibleVC];
}

-(void)dismissFreshchatView{
    [[Freshchat sharedInstance] dismissFreshchatViews];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getSdkVersion" isEqualToString:call.method]) {
        result([Freshchat SDKVersion]);
    } else if([@"init" isEqualToString:call.method]){
        [instance init:call];
    }else if([@"showConversations" isEqualToString:call.method]){
        [instance showConversations];
    }else if([@"showFAQ" isEqualToString:call.method]){
        [instance showFAQs];
    }else if([@"getFreshchatUserId" isEqualToString:call.method]){
        result([instance getFreshchatUserId]);
    }else if([@"trackEvent" isEqualToString:call.method]){
        [instance trackEvent:call];
    }else if([@"setUserProperties" isEqualToString:call.method]){
        [instance setUserProperties:call];
    }else if([@"setBotVariables" isEqualToString:call.method]){
        [instance setBotVariables:call];
    }else if([@"resetUser" isEqualToString:call.method]){
        [instance resetUser];
    }else if([@"setUser" isEqualToString:call.method]){
        [instance setUser:call];
    }else if([@"getUser" isEqualToString:call.method]){
        result([instance getUser]);
    }else if([@"showFAQsWithOptions" isEqualToString:call.method]){
        [instance showFAQsWithOptions:call];
    }else if([@"showConversationsWithOptions" isEqualToString:call.method]){
        [instance showConversationsWithOptions:call];
    }else if([@"showConversationWithReferenceID" isEqualToString:call.method]){
        [instance showConversationWithReferenceID:call];
    }else if([@"sendMessage" isEqualToString:call.method]){
        [instance sendMessage:call];
    }else if([@"getUnreadCountAsync" isEqualToString:call.method]){
        [instance getUnreadCountAsync:result];
    }else if([@"getUnreadCountAsyncForTags" isEqualToString:call.method]){
        [instance getUnreadCountAsyncForTags:call result:result];
    }else if([@"setUserWithIdToken" isEqualToString:call.method]){
        [instance setUserWithIdToken:call];
    }else if([@"restoreUserWithIdToken" isEqualToString:call.method]){
        [instance restoreUserWithJwt:call];
    }else if([@"getUserIdTokenStatus" isEqualToString:call.method]){
        result([instance getUserIdTokenStatus]);
    }else if([@"identifyUser" isEqualToString:call.method]){
        [instance identifyUser:call];
    }else if([@"setNotificationConfig" isEqualToString:call.method]){
        [instance setNotificationConfig];
    }else if([@"setPushRegistrationToken" isEqualToString:call.method]){
        [instance setPushRegistrationToken:call.arguments[@"token"]];
    }else if([@"isFreshchatNotification" isEqualToString:call.method]){
        if([instance isFreshchatNotification:call.arguments[@"pushPayload"]]){
            result(@YES);
        }else{
            result(@NO);
        }
    }else if([@"handlePushNotification" isEqualToString:call.method]){
        [instance handlePushNotification:call.arguments[@"pushPayload"]];
    }else if([@"registerForEvent" isEqualToString:call.method]){
        [instance registerForEvent:call];
    }else if([@"openFreshchatDeeplink" isEqualToString:call.method]){
        [instance registerForEvent:call];
    }else if([@"linkifyWithPattern" isEqualToString:call.method]){
        NSLog(@"Linkify not available for iOS");
    }else if([@"notifyAppLocaleChange" isEqualToString:call.method]){
        NSLog(@"notifyAppLocaleChange not available for iOS");
    } else if([@"dismissFreshchatView" isEqualToString:call.method]){
        [instance dismissFreshchatView];
    }
    else{
        result(FlutterMethodNotImplemented);
    }
}

@end
