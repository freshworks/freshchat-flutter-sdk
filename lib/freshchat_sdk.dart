import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'freshchat_user.dart';

enum FaqFilterType { Article, Category }

enum JwtTokenStatus {
  TOKEN_NOT_SET,
  TOKEN_NOT_PROCESSED,
  TOKEN_VALID,
  TOKEN_INVALID,
  TOKEN_EXPIRED
}

final StreamController restoreIdStreamController = StreamController.broadcast();
final StreamController freshchatEventStreamController =
    StreamController.broadcast();
final StreamController messageCountUpdatesStreamController =
    StreamController.broadcast();
final StreamController linkHandlingStreamController =
    StreamController.broadcast();
final StreamController webviewStreamController = StreamController.broadcast();
final StreamController notificationInterceptController =
    StreamController.broadcast();
final StreamController refreshJwtController = StreamController.broadcast();
final StreamController userInteractionController = StreamController.broadcast();

extension ParseToString on FaqFilterType? {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

enum Priority {
  PRIORITY_DEFAULT,
  PRIORITY_LOW,
  PRIORITY_MIN,
  PRIORITY_HIGH,
  PRIORITY_MAX
}

extension getPriorityValue on Priority {
  int priorityValue() {
    switch (this) {
      case Priority.PRIORITY_DEFAULT:
        return 0;

      case Priority.PRIORITY_LOW:
        return -1;

      case Priority.PRIORITY_MIN:
        return -2;

      case Priority.PRIORITY_HIGH:
        return 1;

      case Priority.PRIORITY_MAX:
        return 2;

      default:
        return 0;
    }
  }
}

enum Importance {
  IMPORTANCE_UNSPECIFIED,
  IMPORTANCE_NONE,
  IMPORTANCE_MIN,
  IMPORTANCE_LOW,
  IMPORTANCE_DEFAULT,
  IMPORTANCE_HIGH,
  IMPORTANCE_MAX
}

extension getImportanceValue on Importance {
  int importanceValue() {
    switch (this) {
      case Importance.IMPORTANCE_UNSPECIFIED:
        return -1000;

      case Importance.IMPORTANCE_NONE:
        return 0;

      case Importance.IMPORTANCE_MIN:
        return 1;

      case Importance.IMPORTANCE_LOW:
        return 2;

      case Importance.IMPORTANCE_DEFAULT:
        return 3;

      case Importance.IMPORTANCE_HIGH:
        return 4;

      case Importance.IMPORTANCE_MAX:
        return 5;

      default:
        return 3;
    }
  }
}

extension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension on List<String>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

const FRESHCHAT_USER_RESTORE_ID_GENERATED =
    "FRESHCHAT_USER_RESTORE_ID_GENERATED";
const FRESHCHAT_EVENTS = "FRESHCHAT_EVENTS";
const FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED =
    "FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED";
const ACTION_OPEN_LINKS = "ACTION_OPEN_LINKS";
const ACTION_LOCALE_CHANGED_BY_WEBVIEW = "ACTION_LOCALE_CHANGED_BY_WEBVIEW";
const FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED =
    "FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED";
const FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES =
    "FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES";
const FRESHCHAT_ACTION_USER_INTERACTION = "FRESHCHAT_ACTION_USER_INTERACTION";

class Freshchat {
  static const MethodChannel _channel = const MethodChannel('freshchat_sdk');

  /// Initialize Freshchat SDK with the necessary configuration
  ///
  /// [appId], [appKey] and [domain] can be found in Mobile SDK settings page of your Freshchat account.
  static void init(String appId, String appKey, String domain,
      {bool responseExpectationEnabled = true,
      bool teamMemberInfoVisible = true,
      bool cameraCaptureEnabled = true,
      bool gallerySelectionEnabled = true,
      bool userEventsTrackingEnabled = true,
      String? stringsBundle,
      String? themeName,
      bool errorLogsEnabled = true,
      bool showNotificationBanneriOS = true,
      bool fileSelectionEnabled = true}) async {
    await _channel.invokeMethod('init', <String, dynamic>{
      'appId': appId,
      'appKey': appKey,
      'domain': domain,
      'responseExpectationEnabled': responseExpectationEnabled,
      'teamMemberInfoVisible': teamMemberInfoVisible,
      'cameraCaptureEnabled': cameraCaptureEnabled,
      'gallerySelectionEnabled': gallerySelectionEnabled,
      'userEventsTrackingEnabled': userEventsTrackingEnabled,
      'stringsBundle': stringsBundle,
      'themeName': themeName,
      'errorLogsEnabled': errorLogsEnabled,
      'showNotificationBanneriOS': showNotificationBanneriOS,
      'fileSelectionEnabled': fileSelectionEnabled
    });
  }

  /// Get the current user's identifier from Freshchat
  static Future<String> get getFreshchatUserId async {
    final String userAlias = await _channel.invokeMethod('getFreshchatUserId');
    return userAlias;
  }

  /// Resets the user stored by Freshchat SDK
  ///
  /// Should be used when user logs out of the application
  static void resetUser() async {
    await _channel.invokeMethod('resetUser');
  }

  /// Sync any change to user information with Freshchat
  ///
  /// [user] is the FreshchatUser object which is constructed with user details
  static void setUser(FreshchatUser user) async {
    await _channel.invokeMethod('setUser', <String, String?>{
      'firstName': user.getFirstName(),
      'lastName': user.getLastName(),
      'email': user.getEmail(),
      'phoneCountryCode': user.getPhoneCountryCode(),
      'phoneNumber': user.getPhone()
    });
  }

  /// Returns an instance of FreshchatUser object, pre-populated with current user information
  static Future<FreshchatUser> get getUser async {
    final Map userDetails = await _channel.invokeMethod('getUser');
    FreshchatUser user =
        new FreshchatUser(userDetails["externalId"], userDetails["restoreId"]);
    if (userDetails["email"] != null) {
      user.setEmail(userDetails["email"]);
    }
    if (userDetails["firstName"] != null) {
      user.setFirstName(userDetails["firstName"]);
    }
    if (userDetails["lastName"] != null) {
      user.setLastName(userDetails["lastName"]);
    }
    if (userDetails["phoneCountryCode"] == null) {
      userDetails["phoneCountryCode"] = "";
    }
    if (userDetails["phone"] == null) {
      userDetails["phone"] = "";
    }
    user.setPhone(userDetails["phoneCountryCode"], userDetails["phone"]);
    return user;
  }

  /// Sync a series of user meta information with Freshchat
  static void setUserProperties(Map propertyMap) async {
    await _channel.invokeMethod('setUserProperties', <String, Map>{
      'propertyMap': propertyMap,
    });
  }

  /// Set bot variables and bot specific variables with Freshchat
  static void setBotVariables(Map botVariables, Map specificVariables) async {
    await _channel.invokeMethod('setBotVariables', <String, Map>{
      'botVariables': botVariables,
      'specificVariables':specificVariables
    });
  }

  /// Get the current Freshchat flutter SDK version as well as the corresponding native SDK version (Android or iOS)
  static Future<String> get getSdkVersion async {
    final String sdkVersion = await _channel.invokeMethod('getSdkVersion');
    final String operatingSystem = Platform.operatingSystem;
    // As there is no simple way to get current freshchat flutter sdk version, we are hardcoding here.
    final String allSdkVersion = "flutter-0.10.23-$operatingSystem-$sdkVersion ";
    return allSdkVersion;
  }

  /// Displays the FAQ Categories Page (Category List Activity) from where users can view and search FAQs
  static void showFAQ(
      {String? faqTitle,
      String? contactUsTitle,
      List<String>? faqTags,
      List<String>? contactUsTags,
      FaqFilterType? faqFilterType,
      bool showContactUsOnFaqScreens = true,
      bool showFaqCategoriesAsGrid = true,
      bool showContactUsOnAppBar = false,
      bool showContactUsOnFaqNotHelpful = true}) async {
    if (faqTitle.isNullOrEmpty &&
        contactUsTitle.isNullOrEmpty &&
        faqTags.isNullOrEmpty &&
        contactUsTags.isNullOrEmpty) {
      await _channel.invokeMethod('showFAQsWithOptions', <String, dynamic>{
        'showContactUsOnFaqScreens': showContactUsOnFaqScreens,
        'showFaqCategoriesAsGrid': showFaqCategoriesAsGrid,
        'showContactUsOnAppBar': showContactUsOnAppBar,
        'showContactUsOnFaqNotHelpful': showContactUsOnFaqNotHelpful
      });
    } else {
      await _channel.invokeMethod(
        'showFAQsWithOptions',
        <String, dynamic>{
          'faqTitle': faqTitle ?? "",
          'contactUsTitle': contactUsTitle ?? "",
          'faqTags': faqTags,
          'contactUsTags': contactUsTags,
          'faqFilterType': faqFilterType!.toShortString(),
          'showContactUsOnFaqScreens': showContactUsOnFaqScreens,
          'showFaqCategoriesAsGrid': showFaqCategoriesAsGrid,
          'showContactUsOnAppBar': showContactUsOnAppBar,
          'showContactUsOnFaqNotHelpful': showContactUsOnFaqNotHelpful
        },
      );
    }
  }

  /// Track an user event with Freshchat
  static void trackEvent(String eventName, {Map? properties}) async {
    await _channel.invokeMethod(
      'trackEvent',
      <String, dynamic>{'eventName': eventName, 'properties': properties},
    );
  }

  /// Retrieve a count of unread messages across all unrestricted/public channels for the user asynchronously.
  static Future<Map> get getUnreadCountAsync async {
    final Map unreadCountStatus =
        await _channel.invokeMethod('getUnreadCountAsync');
    return unreadCountStatus;
  }

  /// Retrieve a count of unread messages for channels with tags.
  static Future<Map> getUnreadCountAsyncForTags(List<String> tags) async {
    final Map unreadCountStatus = await _channel.invokeMethod(
        'getUnreadCountAsyncForTags', <String, List<String>>{'tags': tags});
    return unreadCountStatus;
  }

  /// Displays list of Support Channels (Channel List Activity) through which users can converse with you
  static void showConversations(
      {String? filteredViewTitle, List<String>? tags}) async {
    if (filteredViewTitle == null && tags == null) {
      await _channel.invokeMethod('showConversations');
    } else {
      await _channel.invokeMethod(
        'showConversationsWithOptions',
        <String, dynamic>{'filteredViewTitle': filteredViewTitle, 'tags': tags},
      );
    }
  }

  /// Without proper reference ID, either the default topic, or list of topics will be shown.
  static void showConversationWithReferenceID(String conversationReferenceID, String topicName) async {
    await _channel.invokeMethod(
      'showConversationWithReferenceID',
      <String, String>{'conversationReferenceID': conversationReferenceID, 'topicName': topicName},
    );
  }

  /// Sync any change to user information, specified in JWT Token with Freshchat
  static void setUserWithIdToken(String token) async {
    await _channel.invokeMethod(
      'setUserWithIdToken',
      <String, dynamic>{
        'token': token,
      },
    );
  }

  /// Send a message on behalf of the user to a conversation channel tagged with the provided tag
  ///
  /// Pass the topic name in [tag] and the message to be sent in [message]
  static void sendMessage(String tag, String message) async {
    await _channel.invokeMethod(
      'sendMessage',
      <String, String>{'tag': tag, 'message': message},
    );
  }

  /// Restore an user base on reference_id present in the jwt token
  static void restoreUserWithIdToken(String token) async {
    await _channel.invokeMethod(
      'restoreUserWithIdToken',
      <String, dynamic>{
        'token': token,
      },
    );
  }

  /// Get the status of the jwt id token
  static Future<JwtTokenStatus> get getUserIdTokenStatus async {
    String tokenStatus = await _channel.invokeMethod(
      'getUserIdTokenStatus',
    );
    switch (tokenStatus) {
      case "TOKEN_NOT_SET":
        return JwtTokenStatus.TOKEN_NOT_SET;

      case "TOKEN_NOT_PROCESSED":
        return JwtTokenStatus.TOKEN_NOT_PROCESSED;

      case "TOKEN_VALID":
        return JwtTokenStatus.TOKEN_VALID;

      case "TOKEN_INVALID":
        return JwtTokenStatus.TOKEN_INVALID;

      case "TOKEN_EXPIRED":
        return JwtTokenStatus.TOKEN_EXPIRED;

      default:
        return JwtTokenStatus.TOKEN_NOT_SET;
    }
  }

  /// To identify an user in Freshchat with an unique identifier from your system and restore an user across devices/sessions/platforms based on an external identifier and restore id
  static void identifyUser({required String externalId, String? restoreId}) {
    _channel.invokeMethod(
      'identifyUser',
      <String, String>{'externalId': externalId, 'restoreId': restoreId ?? ""},
    );
  }

  static void _registerForEvent(String eventName, bool shouldRegister) {
    _channel.setMethodCallHandler(_wrapperMethodCallHandler);
    _channel.invokeMethod('registerForEvent', <String, dynamic>{
      'eventName': eventName,
      'shouldRegister': shouldRegister
    });
  }

  static Future<dynamic> _wrapperMethodCallHandler(
      MethodCall methodCall) async {
    switch (methodCall.method) {
      case FRESHCHAT_USER_RESTORE_ID_GENERATED:
        bool? isRestoreIdGenerated = methodCall.arguments;
        restoreIdStreamController.add(isRestoreIdGenerated);
        break;
      case FRESHCHAT_EVENTS:
        Map? event = methodCall.arguments;
        freshchatEventStreamController.add(event);
        break;
      case FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED:
        bool? isMessageCountChanged = methodCall.arguments;
        messageCountUpdatesStreamController.add(isMessageCountChanged);
        break;
      case ACTION_OPEN_LINKS:
        Map? url = methodCall.arguments;
        linkHandlingStreamController.add(url);
        break;
      case ACTION_LOCALE_CHANGED_BY_WEBVIEW:
        Map? map = methodCall.arguments;
        webviewStreamController.add(map);
        break;
      case FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED:
        Map? url = methodCall.arguments;
        print("Rohit flutter: notification event callback received");
        notificationInterceptController.add(url);
        break;
      case FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES:
        Map? isJwtRefresh = methodCall.arguments;
        refreshJwtController.add(isJwtRefresh);
        break;
      case FRESHCHAT_ACTION_USER_INTERACTION:
        Map? userInteraction = methodCall.arguments;
        userInteractionController.add(userInteraction);
        break;
      default:
        print("No such method implementation");
    }
  }

  /// Accepts Notification configurations allowing you to configure all the notification related parameters (Android)
  static void setNotificationConfig(
      {Priority priority = Priority.PRIORITY_DEFAULT,
      Importance importance = Importance.IMPORTANCE_DEFAULT,
      bool notificationSoundEnabled = true,
      bool notificationInterceptionEnabled = false,
      String? largeIcon,
      String? smallIcon}) async {
    await _channel.invokeMethod(
      'setNotificationConfig',
      <String, dynamic>{
        'priority': priority.priorityValue(),
        'importance': importance.importanceValue(),
        'notificationSoundEnabled': notificationSoundEnabled,
        'notificationInterceptionEnabled': notificationInterceptionEnabled,
        'largeIcon': largeIcon,
        'smallIcon': smallIcon,
      },
    );
  }

  /// Allows you to configure the FCM Registration token for the user (Android)
  static void setPushRegistrationToken(String token) async {
    await _channel.invokeMethod('setPushRegistrationToken', <String, String>{
      'token': token,
    });
  }

  /// Check if the notification received with the provided intent is a Freshchat notification or not (Android)
  static Future<bool> isFreshchatNotification(Map pushPayload) async {
    bool isFreshchatNotification =
        await _channel.invokeMethod("isFreshchatNotification", <String, Map>{
      'pushPayload': pushPayload,
    });
    return isFreshchatNotification;
  }

  /// Process the notification information and display a notification to the user as appropriate (Android)
  static void handlePushNotification(Map pushPayload) async {
    await _channel.invokeMethod("handlePushNotification", <String, Map>{
      'pushPayload': pushPayload,
    });
  }

  /// Open Freshchat deeplinks.
  ///
  /// This can be used to open specific channels and specific FAQs specified in the deeplink
  static void openFreshchatDeeplink(String link) {
    _channel.invokeMethod("openFreshchatDeeplink", <String, String>{
      'link': link,
    });
  }

  /// Creates deep links in messages turning the matches into links based on the regex (Android)
  ///
  /// Internally uses {@link android.text.util.Linkify#addLinks(Spannable, Pattern, String)}
  /// The given regex is converted into a pattern and passed to the addLinks method.
  static void linkifyWithPattern(String regex, String defaultScheme) {
    _channel.invokeMethod("linkifyWithPattern",
        <String, String>{'regex': regex, 'defaultScheme': defaultScheme});
  }

  /// Notify any locale change that happens during runtime to Freshchat (Android)
  static void notifyAppLocaleChange() {
    _channel.invokeMethod("notifyAppLocaleChange");
  }

  /// Dismiss freshchat screen, if currently visible.
  static void dismissFreshchatView() {
    _channel.invokeMethod("dismissFreshchatView");
  }

  /// Stream which triggers a callback if the restoreID is generated for the user
  static Stream get onRestoreIdGenerated {
    restoreIdStreamController.onCancel = () {
      _registerForEvent(FRESHCHAT_USER_RESTORE_ID_GENERATED, false);
    };
    restoreIdStreamController.onListen = () {
      _registerForEvent(FRESHCHAT_USER_RESTORE_ID_GENERATED, true);
    };
    return restoreIdStreamController.stream;
  }

  /// Stream which sends the user events for Freshchat
  static Stream get onFreshchatEvents {
    freshchatEventStreamController.onCancel = () {
      _registerForEvent(FRESHCHAT_EVENTS, false);
    };
    freshchatEventStreamController.onListen = () {
      _registerForEvent(FRESHCHAT_EVENTS, true);
    };
    return freshchatEventStreamController.stream;
  }

  /// Stream which triggers a callback for every unread message
  static Stream get onMessageCountUpdate {
    messageCountUpdatesStreamController.onCancel = () {
      _registerForEvent(FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED, false);
    };
    messageCountUpdatesStreamController.onListen = () {
      _registerForEvent(FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED, true);
    };
    return messageCountUpdatesStreamController.stream;
  }

  /// Stream which sends any links opened by user within Freshchat
  static Stream get onRegisterForOpeningLink {
    linkHandlingStreamController.onCancel = () {
      _registerForEvent(ACTION_OPEN_LINKS, false);
    };
    linkHandlingStreamController.onListen = () {
      _registerForEvent(ACTION_OPEN_LINKS, true);
    };
    return linkHandlingStreamController.stream;
  }

  /// Stream which triggers a callback on locale change when in webview
  static Stream get onLocaleChangedByWebView {
    webviewStreamController.onCancel = () {
      _registerForEvent(ACTION_LOCALE_CHANGED_BY_WEBVIEW, false);
    };
    webviewStreamController.onListen = () {
      _registerForEvent(ACTION_LOCALE_CHANGED_BY_WEBVIEW, true);
    };
    return webviewStreamController.stream;
  }

  /// Stream which triggers a callback on clicking notification
  static Stream get onNotificationIntercept {
    notificationInterceptController.onCancel = () {
      _registerForEvent(FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED, false);
    };
    notificationInterceptController.onListen = () {
      _registerForEvent(FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED, true);
    };
    return notificationInterceptController.stream;
  }

  /// Stream which triggers a callback on JWT token refresh
  static Stream get onJwtRefresh {
    refreshJwtController.onCancel = () {
      _registerForEvent(
          FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES, false);
    };
    refreshJwtController.onListen = () {
      _registerForEvent(FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES, true);
    };
    return refreshJwtController.stream;
  }

  /// Stream which triggers a callback on user interaction in SDK
  static Stream get onUserInteraction {
    userInteractionController.onCancel = () {
      _registerForEvent(FRESHCHAT_ACTION_USER_INTERACTION, false);
    };
    userInteractionController.onListen = () {
      _registerForEvent(FRESHCHAT_ACTION_USER_INTERACTION, true);
    };
    return userInteractionController.stream;
  }
}
