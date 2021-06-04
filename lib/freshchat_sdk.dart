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
final StreamController freshchatEventStreamController = StreamController.broadcast();
final StreamController messageCountUpdatesStreamController = StreamController.broadcast();
final StreamController linkHandlingStreamController = StreamController.broadcast();
final StreamController webviewStreamController = StreamController.broadcast();

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
        break;

      case Priority.PRIORITY_LOW:
        return -1;
        break;

      case Priority.PRIORITY_MIN:
        return -2;
        break;

      case Priority.PRIORITY_HIGH:
        return 1;
        break;

      case Priority.PRIORITY_MAX:
        return 2;
        break;

      default:
        return 0;
        break;
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
        break;

      case Importance.IMPORTANCE_NONE:
        return 0;
        break;

      case Importance.IMPORTANCE_MIN:
        return 1;
        break;

      case Importance.IMPORTANCE_LOW:
        return 2;
        break;

      case Importance.IMPORTANCE_DEFAULT:
        return 3;
        break;

      case Importance.IMPORTANCE_HIGH:
        return 4;
        break;

      case Importance.IMPORTANCE_MAX:
        return 5;
        break;

      default:
        return 3;
        break;
    }
  }
}

const FRESHCHAT_USER_RESTORE_ID_GENERATED =
    "FRESHCHAT_USER_RESTORE_ID_GENERATED";
const FRESHCHAT_EVENTS = "FRESHCHAT_EVENTS";
const FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED =
    "FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED";
const ACTION_OPEN_LINKS = "ACTION_OPEN_LINKS";
const ACTION_LOCALE_CHANGED_BY_WEBVIEW = "ACTION_LOCALE_CHANGED_BY_WEBVIEW";

class Freshchat {
  static const MethodChannel _channel = const MethodChannel('freshchat_sdk');

  static void init(String appId, String appKey, String domain,
      {bool responseExpectationEnabled = true,
      bool teamMemberInfoVisible = true,
      bool cameraCaptureEnabled = true,
      bool gallerySelectionEnabled = true,
      bool userEventsTrackingEnabled = true,
      String? stringsBundle,
      String? themeName,
      bool errorLogsEnabled = true}) async {
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
      'errorLogsEnabled': errorLogsEnabled
    });
  }

  static Future<String?> get getUserAlias async {
    final String? userAlias = await _channel.invokeMethod('getUserAlias');
    return userAlias;
  }

  static void resetUser() async {
    await _channel.invokeMethod('resetUser');
  }

  static void setUser(FreshchatUser user) async {
    await _channel.invokeMethod('setUser', <String, String?>{
      'firstName': user.getFirstName(),
      'lastName': user.getLastName(),
      'email': user.getEmail(),
      'phoneCountryCode': user.getPhoneCountryCode(),
      'phoneNumber': user.getPhone()
    });
  }

  static Future<FreshchatUser> get getUser async {
    final Map userDetails = await (_channel.invokeMethod('getUser') as FutureOr<Map<dynamic, dynamic>>);
    FreshchatUser user =
        new FreshchatUser(userDetails["externalId"], userDetails["restoreId"]);
    user.setEmail(userDetails["email"]);
    user.setFirstName(userDetails["firstName"]);
    user.setLastName(userDetails["lastName"]);
    user.setPhone(userDetails["phoneCountryCode"], userDetails["phone"]);
    return user;
  }

  static void setUserProperties(Map propertyMap) async {
    await _channel.invokeMethod('setUserProperties', <String, Map>{
      'propertyMap': propertyMap,
    });
  }

  static Future<String> get getSdkVersion async {
    final String? sdkVersion = await _channel.invokeMethod('getSdkVersion');
    final String operatingSystem = Platform.operatingSystem;
    // As there is no simple way to get current freshchat flutter sdk version, we are hardcoding here.
    final String allSdkVersion = "flutter-0.6.0-$operatingSystem-$sdkVersion ";
    return allSdkVersion;
  }

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
    if (faqTitle == null &&
        contactUsTitle == null &&
        faqTags == null &&
        contactUsTags == null) {
      await _channel.invokeMethod('showFAQ');
    } else {
      await _channel.invokeMethod(
        'showFAQsWithOptions',
        <String, dynamic>{
          'faqTitle': faqTitle,
          'contactUsTitle': contactUsTitle,
          'faqTags': faqTags,
          'contactUsTags': contactUsTags,
          'faqFilterType': faqFilterType.toShortString(),
          'showContactUsOnFaqScreens': showContactUsOnFaqScreens,
          'showFaqCategoriesAsGrid': showFaqCategoriesAsGrid,
          'showContactUsOnAppBar': showContactUsOnAppBar,
          'showContactUsOnFaqNotHelpful': showContactUsOnFaqNotHelpful
        },
      );
    }
  }

  static void trackEvent(String eventName, {Map? properties}) async {
    await _channel.invokeMethod(
      'trackEvent',
      <String, dynamic>{'eventName': eventName, 'properties': properties},
    );
  }

  static Future<Map?> get getUnreadCountAsync async {
    final Map? unreadCountStatus =
        await _channel.invokeMethod('getUnreadCountAsync');
    return unreadCountStatus;
  }

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

  static void setUserWithIdToken(String token) async {
    await _channel.invokeMethod(
      'setUserWithIdToken',
      <String, dynamic>{
        'token': token,
      },
    );
  }

  static void sendMessage(String tag, String message) async {
    await _channel.invokeMethod(
      'sendMessage',
      <String, String>{'tag': tag, 'message': message},
    );
  }

  static void restoreUserWithIdToken(String token) async {
    await _channel.invokeMethod(
      'restoreUserWithIdToken',
      <String, dynamic>{
        'token': token,
      },
    );
  }

  static Future<JwtTokenStatus> get getUserIdTokenStatus async {
    String? tokenStatus = await _channel.invokeMethod(
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

  static void identifyUser({String? externalId, String? restoreId}) {
    _channel.invokeMethod(
      'identifyUser',
      <String, String>{
        'externalId': externalId ?? "",
        'restoreId': restoreId ?? ""
      },
    );
  }

  static void registerForEvent(String eventName, bool shouldRegister) {
    _channel.setMethodCallHandler(wrapperMethodCallHandler);
    _channel.invokeMethod('registerForEvent', <String, dynamic>{
      'eventName': eventName,
      'shouldRegister': shouldRegister
    });
  }

  static Future<dynamic> wrapperMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case FRESHCHAT_USER_RESTORE_ID_GENERATED:
        bool? isRestoreIdGenerated = methodCall.arguments;
        restoreIdStreamController.add(isRestoreIdGenerated);
        break;
      case FRESHCHAT_EVENTS:
        Map? event = methodCall.arguments;
        freshchatEventStreamController.add(event);
        break;
      case FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED:
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
      default:
        print("No such method implementation");
    }
  }

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

  static void setPushRegistrationToken(String token) async {
    await _channel.invokeMethod('setPushRegistrationToken', <String, String>{
      'token': token,
    });
  }

  static Future<bool?> isFreshchatNotification(Map pushPayload) async {
    bool? isFreshchatNotification =
        await _channel.invokeMethod("isFreshchatNotification", <String, Map>{
      'pushPayload': pushPayload,
    });
    return isFreshchatNotification;
  }

  static void handlePushNotification(Map pushPayload) async {
    await _channel.invokeMethod("handlePushNotification", <String, Map>{
      'pushPayload': pushPayload,
    });
  }

  static void openFreshchatDeeplink(String link) {
    _channel.invokeMethod("openFreshchatDeeplink", <String, String>{
      'link': link,
    });
  }

  static void linkifyWithPattern(String regex, String defaultScheme) {
    _channel.invokeMethod("linkifyWithPattern",
        <String, String>{'regex': regex, 'defaultScheme': defaultScheme});
  }

  static void notifyAppLocaleChange() {
    _channel.invokeMethod("notifyAppLocaleChange");
  }

  static Stream get onRestoreIdGenerated {
    restoreIdStreamController.onCancel = () {
      registerForEvent(FRESHCHAT_USER_RESTORE_ID_GENERATED, false);
    };
    restoreIdStreamController.onListen = () {
      registerForEvent(FRESHCHAT_USER_RESTORE_ID_GENERATED, true);
    };
    return restoreIdStreamController.stream;
  }

  static Stream get onFreshchatEvents {
    freshchatEventStreamController.onCancel = () {
      registerForEvent(FRESHCHAT_EVENTS, false);
    };
    freshchatEventStreamController.onListen = () {
      registerForEvent(FRESHCHAT_EVENTS, true);
    };
    return freshchatEventStreamController.stream;
  }

  static Stream get onMessageCountUpdate {
    messageCountUpdatesStreamController.onCancel = () {
      registerForEvent(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED, false);
    };
    messageCountUpdatesStreamController.onListen = () {
      registerForEvent(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED, true);
    };
    return messageCountUpdatesStreamController.stream;
  }

  static Stream get onRegisterForOpeningLink {
    linkHandlingStreamController.onCancel = () {
      registerForEvent(ACTION_OPEN_LINKS, false);
    };
    linkHandlingStreamController.onListen = () {
      registerForEvent(ACTION_OPEN_LINKS, true);
    };
    return linkHandlingStreamController.stream;
  }

  static Stream get onLocaleChangedByWebView {
    webviewStreamController.onCancel = () {
      registerForEvent(ACTION_LOCALE_CHANGED_BY_WEBVIEW, false);
    };
    webviewStreamController.onListen = () {
      registerForEvent(ACTION_LOCALE_CHANGED_BY_WEBVIEW, true);
    };
    return webviewStreamController.stream;
  }
}
