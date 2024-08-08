package com.freshchat.consumer.sdk.flutter;


import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.content.BroadcastReceiver;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import android.content.IntentFilter;
import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;


import com.freshchat.consumer.sdk.ConversationOptions;
import com.freshchat.consumer.sdk.Event;
import com.freshchat.consumer.sdk.FaqOptions;
import com.freshchat.consumer.sdk.FreshchatCallbackStatus;
import com.freshchat.consumer.sdk.FreshchatConfig;
import com.freshchat.consumer.sdk.Freshchat;
import com.freshchat.consumer.sdk.FreshchatMessage;
import com.freshchat.consumer.sdk.FreshchatNotificationConfig;
import com.freshchat.consumer.sdk.FreshchatUserInteractionListener;
import com.freshchat.consumer.sdk.FreshchatUser;
import com.freshchat.consumer.sdk.FreshchatWebViewListener;
import com.freshchat.consumer.sdk.JwtTokenStatus;
import com.freshchat.consumer.sdk.LinkHandler;
import com.freshchat.consumer.sdk.UnreadCountCallback;

import java.lang.ref.WeakReference;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * FreshchatSdkPlugin
 */
public class FreshchatSdkPlugin implements FlutterPlugin, MethodCallHandler {

    public static final String PLUGIN_KEY = "com.freshchat.consumer.sdk.flutter";

    private MethodChannel channel;
    private FreshchatConfig freshchatConfig;
    private Context context;

    private FreshchatSDKBroadcastReceiver restoreIdUpdatesReceiver;
    private FreshchatSDKBroadcastReceiver userActionsReceiver;
    private FreshchatSDKBroadcastReceiver messageCountUpdatesReceiver;
    private FreshchatSDKBroadcastReceiver notificationClickReceiver;
    private FreshchatSDKBroadcastReceiver jwtRefreshEventReceiver;
    private FreshchatSDKBroadcastReceiver userInteractionReceiver;
    private static final String LOG_TAG = "FRESHCHAT_FLUTTER";
    private static final String ERROR_TAG = "FRESHCHAT_ERROR";
    private static final String FRESHCHAT_USER_RESTORE_ID_GENERATED = "FRESHCHAT_USER_RESTORE_ID_GENERATED";
    private static final String FRESHCHAT_EVENTS = "FRESHCHAT_EVENTS";
    private static final String FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED = "FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED";
    private static final String ACTION_OPEN_LINKS = "ACTION_OPEN_LINKS";
    private static final String ACTION_LOCALE_CHANGED_BY_WEBVIEW = "ACTION_LOCALE_CHANGED_BY_WEBVIEW";
    private static final String FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED = "FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED";
    private static final String FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES = "FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES";
    private static final String FRESHCHAT_ACTION_USER_INTERACTION = "FRESHCHAT_ACTION_USER_INTERACTION";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        setupPlugin(flutterPluginBinding.getApplicationContext(),
                flutterPluginBinding.getBinaryMessenger(),
                this);
    }

    public static void register(@NonNull PluginRegistry registry) {
        if (registry == null) {
            return;
        }

        registerWith(registry.registrarFor(PLUGIN_KEY));
    }

    // Keeping this public so it cane be used if needed
    public static void registerWith(Registrar registrar) {
        setupPlugin(registrar.context().getApplicationContext(),
                registrar.messenger(),
                new FreshchatSdkPlugin());
    }

    public static void setupPlugin(@NonNull Context context,
                                   @NonNull BinaryMessenger messenger,
                                   @NonNull FreshchatSdkPlugin freshchatSdkPlugin) {
        freshchatSdkPlugin.context = context;
        freshchatSdkPlugin.channel = new MethodChannel(messenger, "freshchat_sdk");
        freshchatSdkPlugin.channel.setMethodCallHandler(freshchatSdkPlugin);
        freshchatSdkPlugin.restoreIdUpdatesReceiver = freshchatSdkPlugin.new FreshchatSDKBroadcastReceiver(context, Freshchat.FRESHCHAT_USER_RESTORE_ID_GENERATED);
        freshchatSdkPlugin.userActionsReceiver = freshchatSdkPlugin.new FreshchatSDKBroadcastReceiver(context, Freshchat.FRESHCHAT_EVENTS);
        freshchatSdkPlugin.messageCountUpdatesReceiver = freshchatSdkPlugin.new FreshchatSDKBroadcastReceiver(context, Freshchat.FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED);
        freshchatSdkPlugin.notificationClickReceiver = freshchatSdkPlugin.new FreshchatSDKBroadcastReceiver(context,Freshchat.FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED);
        freshchatSdkPlugin.jwtRefreshEventReceiver = freshchatSdkPlugin.new FreshchatSDKBroadcastReceiver(context, Freshchat.FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES);
    }

    public Bundle jsonToBundle(@NonNull Map messageMap) {
        Bundle bundle = new Bundle();
        if (messageMap.size() == 0) {
            return bundle;
        }
        Log.i("message in bundle", "Message map in bundle: " + messageMap);
        Iterator<Map.Entry> it = messageMap.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = it.next();
            if (pair.getValue() instanceof String) {
                bundle.putString(pair.getKey().toString(), pair.getValue().toString());
            } else if (pair.getValue() instanceof Double) {
                bundle.putDouble(pair.getKey().toString(), ((Double) pair.getValue()).doubleValue());
            } else if (pair.getValue() instanceof Boolean) {
                bundle.putBoolean(pair.getKey().toString(), ((Boolean) pair.getValue()).booleanValue());
            } else if (pair.getValue() instanceof Long) {
                bundle.putLong(pair.getKey().toString(), ((Long) pair.getValue()).longValue());
            } else if (pair.getValue() instanceof Integer) {
                bundle.putInt(pair.getKey().toString(), ((Integer) pair.getValue()).intValue());
            } else {
                bundle.putString(pair.getKey().toString(), pair.getValue().toString());
            }
        }
        return bundle;
    }

    public void init(MethodCall call) {
        try {
            String appId = call.argument("appId");
            String appKey = call.argument("appKey");
            String domain = call.argument("domain");
            boolean responseExpectationEnabled = call.argument("responseExpectationEnabled");
            boolean teamMemberInfoVisible = call.argument("teamMemberInfoVisible");
            boolean cameraCaptureEnabled = call.argument("cameraCaptureEnabled");
            boolean gallerySelectionEnabled = call.argument("gallerySelectionEnabled");
            boolean userEventsTrackingEnabled = call.argument("userEventsTrackingEnabled");
            boolean fileSelectionEnabled = call.argument("fileSelectionEnabled");
            freshchatConfig = new FreshchatConfig(appId, appKey);
            freshchatConfig.setDomain(domain);
            freshchatConfig.setResponseExpectationEnabled(responseExpectationEnabled);
            freshchatConfig.setTeamMemberInfoVisible(teamMemberInfoVisible);
            freshchatConfig.setGallerySelectionEnabled(gallerySelectionEnabled);
            freshchatConfig.setUserEventsTrackingEnabled(userEventsTrackingEnabled);
            freshchatConfig.setCameraCaptureEnabled(cameraCaptureEnabled);
            freshchatConfig.setFileSelectionEnabled(fileSelectionEnabled);
            Freshchat.getInstance(context).init(freshchatConfig);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void showFAQ() {
        FaqOptions faqOptions = new FaqOptions();
        Freshchat.showFAQs(context, faqOptions);
    }

    public void showConversations() {
        Freshchat.showConversations(context);
    }

    public String getFreshchatUserId() {
        return Freshchat.getInstance(context).getFreshchatUserId();
    }

    public void resetUser() {
        Freshchat.getInstance(context).resetUser(context);
    }

    public void setUser(MethodCall call) {
        final FreshchatUser freshchatUser = Freshchat.getInstance(context).getUser();
        try {
            String firstName = call.argument("firstName");
            String lastName = call.argument("lastName");
            String email = call.argument("email");
            String phoneCountryCode = call.argument("phoneCountryCode");
            String phoneNumber = call.argument("phoneNumber");
            freshchatUser.setFirstName(firstName);
            freshchatUser.setLastName(lastName);
            freshchatUser.setEmail(email);
            freshchatUser.setPhone(phoneCountryCode, phoneNumber);
            Freshchat.getInstance(context).setUser(freshchatUser);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public Map<String, String> getUser() {
        final FreshchatUser freshchatUser = Freshchat.getInstance(context).getUser();
        Map<String, String> userDetails = new HashMap<>();
        userDetails.put("email", freshchatUser.getEmail());
        userDetails.put("firstName", freshchatUser.getFirstName());
        userDetails.put("lastName", freshchatUser.getLastName());
        userDetails.put("phone", freshchatUser.getPhone());
        userDetails.put("phoneCountryCode", freshchatUser.getPhoneCountryCode());
        userDetails.put("externalId", freshchatUser.getExternalId());
        userDetails.put("restoreId", freshchatUser.getRestoreId());
        return userDetails;
    }

    public void setUserProperties(MethodCall call) {
        try {
            Map propertyMap = call.argument("propertyMap");
            Freshchat.getInstance(context).setUserProperties(propertyMap);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void setBotVariables(MethodCall call) {
        try {
            Map botVariablesMap = call.argument("botVariables");
            Map specificVariablesMap = call.argument("specificVariables");
            Freshchat.getInstance(context).setBotVariables(botVariablesMap, specificVariablesMap);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public String sdkVersion() {
        return "6.2.8";
    }

    public void showFAQsWithOptions(MethodCall call) {
        try {
            List<String> faqTags = call.argument("faqTags");
            List<String> contactUsTags = call.argument("contactUsTags");
            String faqTitle = call.argument("faqTitle");
            String faqFilterType = call.argument("faqFilterType");
            String contactUsTitle = call.argument("contactUsTitle");
            boolean showContactUsOnFaqScreens = call.argument("showContactUsOnFaqScreens");
            boolean showFaqCategoriesAsGrid = call.argument("showFaqCategoriesAsGrid");
            boolean showContactUsOnAppBar = call.argument("showContactUsOnAppBar");
            boolean showContactUsOnFaqNotHelpful = call.argument("showContactUsOnFaqNotHelpful");
            FaqOptions faqOptions = new FaqOptions();
            FaqOptions.FilterType filterType;
            filterType = FaqOptions.FilterType.ARTICLE;
            if (faqFilterType != null) {
                if (faqFilterType.equals("Article")) {
                    filterType = FaqOptions.FilterType.ARTICLE;
                } else if (faqFilterType.equals("Category")) {
                    filterType = FaqOptions.FilterType.CATEGORY;
                }
            }
            faqOptions.filterByTags(faqTags, faqTitle, filterType);
            faqOptions.showContactUsOnFaqScreens(showContactUsOnFaqScreens);
            faqOptions.showFaqCategoriesAsGrid(showFaqCategoriesAsGrid);
            faqOptions.showContactUsOnAppBar(showContactUsOnAppBar);
            faqOptions.showContactUsOnFaqNotHelpful(showContactUsOnFaqNotHelpful);
            faqOptions.filterContactUsByTags(contactUsTags, contactUsTitle);
            Freshchat.showFAQs(context, faqOptions);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void sendMessage(MethodCall call) {
        try {
            String tag = call.argument("tag");
            String message = call.argument("message");
            FreshchatMessage freshchatMessage = new FreshchatMessage().setTag(tag).setMessage(message);
            Freshchat.sendMessage(context, freshchatMessage);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void trackEvent(MethodCall call) {
        try {
            String eventName = call.argument("eventName");
            Map properties = call.argument("properties");
            Freshchat.trackEvent(context, eventName, properties);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void getUnreadCountAsync(final Result result) {
        UnreadCountCallback unreadCountCallback = new UnreadCountCallback() {
            @Override
            public void onResult(FreshchatCallbackStatus status, int count) {
                Map unreadCountStatus = new HashMap<>();
                unreadCountStatus.put("count", count);
                unreadCountStatus.put("status", status.name());
                result.success(unreadCountStatus);
            }
        };
        Freshchat.getInstance(context).getUnreadCountAsync(unreadCountCallback);
    }

    public void getUnreadCountAsyncForTags(MethodCall call, final Result result) {
        List<String> tags = call.argument("tags");
        UnreadCountCallback unreadCountCallback = new UnreadCountCallback() {
            @Override
            public void onResult(FreshchatCallbackStatus status, int count) {
                Map unreadCountStatus = new HashMap<>();
                unreadCountStatus.put("count", count);
                unreadCountStatus.put("status", status.name());
                result.success(unreadCountStatus);
            }
        };
        Freshchat.getInstance(context).getUnreadCountAsync(unreadCountCallback, tags);
    }

    public void showConversationsWithOptions(MethodCall call) {
        try {
            List<String> tags = call.argument("tags");
            String filteredViewTitle = call.argument("filteredViewTitle");
            ConversationOptions conversationOptions = new ConversationOptions();
            conversationOptions.filterByTags(tags, filteredViewTitle);
            Freshchat.showConversations(context, conversationOptions);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void showConversationWithReferenceID(MethodCall call) {
        try {
            String conversationReferenceID = call.argument("conversationReferenceID");
            String topicName = call.argument("topicName");
            Freshchat.showConversations(context, conversationReferenceID, topicName);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void setUserWithIdToken(MethodCall call) {
        try {
            String token = call.argument("token");
            Freshchat.getInstance(context).setUser(token);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void restoreUserWithIdToken(MethodCall call) {
        try {
            String restoreToken = call.argument("token");
            Freshchat.getInstance(context).restoreUser(restoreToken);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public String getUserIdTokenStatus() {
        JwtTokenStatus newTokenStatus = Freshchat.getInstance(context).getUserIdTokenStatus();
        String status = newTokenStatus.toString();
        return status;
    }


    public void identifyUser(MethodCall call) {
        String externalId = call.argument("externalId");
        String restoreId = call.argument("restoreId");
        try {
            Freshchat.getInstance(context).identifyUser(externalId, restoreId);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    private void registerBroadcastReceiver(@NonNull final FreshchatSDKBroadcastReceiver receiver, @NonNull final String action) {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(action);
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver, intentFilter);
    }

    private void unregisterBroadcastReceiver(@NonNull FreshchatSDKBroadcastReceiver receiver) {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver);
    }

    private LinkHandler linkHandler = new LinkHandler() {
        @Override
        public boolean handleLink(@NonNull String url, Bundle bundle) {
            Map map = new HashMap<>();
            map.put("url", url);
            channel.invokeMethod(ACTION_OPEN_LINKS, map);
            return true;
        }
    };

    public void registerForOpeningLink(boolean shouldHandle) {
        if (shouldHandle) {
            Freshchat.getInstance(context).setCustomLinkHandler(linkHandler);
        } else {
            Freshchat.getInstance(context).setCustomLinkHandler(null);
        }
    }

    private FreshchatUserInteractionListener userInteractionListener = new FreshchatUserInteractionListener() {

        @Override
        public void onUserInteraction() {
            channel.invokeMethod(FRESHCHAT_ACTION_USER_INTERACTION, null);
        }

        @Override
        public void onUserLeaveHint() {
            channel.invokeMethod(FRESHCHAT_ACTION_USER_INTERACTION, null);
        }
    };

    public void registerForEvent(MethodCall call) {
        String eventName = call.argument("eventName");
        boolean shouldRegister = call.argument("shouldRegister");
        switch (eventName) {
            case FRESHCHAT_USER_RESTORE_ID_GENERATED:
                if (shouldRegister) {
                    registerBroadcastReceiver(restoreIdUpdatesReceiver, Freshchat.FRESHCHAT_USER_RESTORE_ID_GENERATED);
                } else {
                    unregisterBroadcastReceiver(restoreIdUpdatesReceiver);
                }
                break;
            case FRESHCHAT_EVENTS:
                if (shouldRegister) {
                    registerBroadcastReceiver(userActionsReceiver, Freshchat.FRESHCHAT_EVENTS);
                } else {
                    unregisterBroadcastReceiver(userActionsReceiver);
                }
                break;
            case FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED:
                if (shouldRegister) {
                    registerBroadcastReceiver(messageCountUpdatesReceiver, Freshchat.FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED);
                } else {
                    unregisterBroadcastReceiver(messageCountUpdatesReceiver);
                }
                break;
            case FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED:
                if (shouldRegister){
                    registerBroadcastReceiver(notificationClickReceiver, Freshchat.FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED);
                } else {
                    unregisterBroadcastReceiver(notificationClickReceiver);
                }
                break;
            case FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES:
                if (shouldRegister){
                    registerBroadcastReceiver(jwtRefreshEventReceiver, Freshchat.FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES);
                } else {
                    unregisterBroadcastReceiver(jwtRefreshEventReceiver);
                }
                break;
            case ACTION_OPEN_LINKS:
                registerForOpeningLink(shouldRegister);
                break;
            case ACTION_LOCALE_CHANGED_BY_WEBVIEW:
                registerForLocaleChangedByWebview(shouldRegister);
                break;
            case FRESHCHAT_ACTION_USER_INTERACTION:
                if (shouldRegister){
                    Freshchat.getInstance(context).setFreshchatUserInteractionListener(userInteractionListener);
                }else{
                    Freshchat.getInstance(context).setFreshchatUserInteractionListener(null);
                }
                break;
            default:
                Log.e(ERROR_TAG, "Invalid event name passed for register: " + eventName);
        }
    }

    public void setNotificationConfig(MethodCall call) {
        try {
            boolean notificationSoundEnabled = call.argument("notificationSoundEnabled");
            boolean notificationInterceptionEnabled = call.argument("notificationInterceptionEnabled");
            int priority = call.argument("priority");
            int importance = call.argument("importance");
            String largeIcon = call.argument("largeIcon");
            String smallIcon = call.argument("smallIcon");
            FreshchatNotificationConfig freshchatNotificationConfig = new FreshchatNotificationConfig();
            freshchatNotificationConfig.setNotificationSoundEnabled(notificationSoundEnabled)
                    .setNotificationInterceptionEnabled(notificationInterceptionEnabled)
                    .setImportance(importance)
                    .setPriority(priority);
            if (largeIcon != null) {
                int largeIconId = context.getResources().getIdentifier(largeIcon, "drawable", context.getPackageName());
                freshchatNotificationConfig.setLargeIcon(largeIconId);
            }
            if (smallIcon != null) {
                int smallIconId = context.getResources().getIdentifier(smallIcon, "drawable", context.getPackageName());
                freshchatNotificationConfig.setSmallIcon(smallIconId);
            }
            Freshchat.getInstance(context).setNotificationConfig(freshchatNotificationConfig);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public void setPushRegistrationToken(MethodCall call) {
        try {
            String token = call.argument("token");
            Freshchat.getInstance(context).setPushRegistrationToken(token);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }

    public boolean isFreshchatNotification(MethodCall call) {

        try {
            Map pushPayload = call.argument("pushPayload");
            Bundle pushPayloadBundle = jsonToBundle(pushPayload);
            return Freshchat.isFreshchatNotification(pushPayloadBundle);

        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
            return false;
        }
    }

    public void handlePushNotification(MethodCall call) {
        try {
            Map pushPayload = call.argument("pushPayload");
            Bundle pushPayloadBundle = jsonToBundle(pushPayload);
            Freshchat.handleFcmMessage(context, pushPayloadBundle);
        } catch (Exception e) {
            Log.e(ERROR_TAG, e.toString());
        }
    }


    private FreshchatWebViewListener webviewListener = new FreshchatWebViewListener() {
        @Override
        public void onLocaleChangedByWebView(@NonNull WeakReference<Context> activityContext) {
            Map map = new HashMap<>();
            channel.invokeMethod(ACTION_LOCALE_CHANGED_BY_WEBVIEW, map);
        }
    };

    public void registerForLocaleChangedByWebview(boolean register) {
        Log.i(LOG_TAG, "registerForLocaleChangedByWebview: " + register);
        if (register) {
            Freshchat.getInstance(context).setWebviewListener(webviewListener);
        } else {
            Freshchat.getInstance(context).setWebviewListener(null);
        }
    }

    public void openFreshchatDeeplink(MethodCall call) {
        String link = call.argument("link");
        Log.i(LOG_TAG, "openFreshchatDeeplink: " + link);
        Freshchat.openFreshchatDeeplink(context, link);
    }

    public void linkifyWithPattern(MethodCall call) {
        String regex = call.argument("regex");
        String defaultScheme = call.argument("defaultScheme");
        Freshchat.getInstance(context).linkifyWithPattern(regex, defaultScheme);
    }

    public void notifyAppLocaleChange() {
        Freshchat.notifyAppLocaleChange(context);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        try {

            switch (call.method) {

                case "init":
                    init(call);
                    break;

                case "showFAQ":
                    showFAQ();
                    break;

                case "showConversations":
                    showConversations();
                    break;

                case "getFreshchatUserId":
                    result.success(getFreshchatUserId());
                    break;

                case "resetUser":
                    resetUser();
                    break;

                case "setUser":
                    setUser(call);
                    break;

                case "getUser":
                    result.success(getUser());
                    break;

                case "setUserProperties":
                    setUserProperties(call);
                    break;

                case "setBotVariables":
                    setBotVariables(call);
                    break;

                case "getSdkVersion":
                    result.success(sdkVersion());
                    break;

                case "showFAQsWithOptions":
                    showFAQsWithOptions(call);
                    break;

                case "sendMessage":
                    sendMessage(call);
                    break;

                case "trackEvent":
                    trackEvent(call);
                    break;

                case "getUnreadCountAsync":
                    getUnreadCountAsync(result);
                    break;

                case "getUnreadCountAsyncForTags":
                    getUnreadCountAsyncForTags(call, result);
                    break;

                case "showConversationsWithOptions":
                    showConversationsWithOptions(call);
                    break;

                case "showConversationWithReferenceID":
                    showConversationWithReferenceID(call);
                    break;

                case "setUserWithIdToken":
                    setUserWithIdToken(call);
                    break;

                case "restoreUserWithIdToken":
                    restoreUserWithIdToken(call);
                    break;

                case "getUserIdTokenStatus":
                    result.success(getUserIdTokenStatus());
                    break;

                case "identifyUser":
                    identifyUser(call);
                    break;

                case "registerForEvent":
                    registerForEvent(call);
                    break;

                case "setNotificationConfig":
                    setNotificationConfig(call);
                    break;

                case "setPushRegistrationToken":
                    setPushRegistrationToken(call);
                    break;

                case "isFreshchatNotification":
                    result.success(isFreshchatNotification(call));
                    break;

                case "handlePushNotification":
                    handlePushNotification(call);
                    break;

                case "openFreshchatDeeplink":
                    openFreshchatDeeplink(call);
                    break;

                case "linkifyWithPattern":
                    linkifyWithPattern(call);
                    break;

                case "notifyAppLocaleChange":
                    notifyAppLocaleChange();
                    break;

                default:
                    result.notImplemented();
                    break;

            }
        } catch (Exception e) {
            result.notImplemented();
        }
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public class FreshchatSDKBroadcastReceiver extends BroadcastReceiver {

        private final Context context;
        private final String eventName;

        public FreshchatSDKBroadcastReceiver(@NonNull Context context, @NonNull String eventName) {
            this.context = context;
            this.eventName = eventName;
        }

        @Override
        public void onReceive(@NonNull Context context, @NonNull Intent intent) {
            String action = intent.getAction();
            Log.i("broadcast tag", "Broadcast triggered: " + action);
            Log.i("event", eventName);
            Map data = new HashMap<>();

            if (context == null) {
                Log.e(ERROR_TAG, "Context is null. Broadcast dropped.");
                return;
            }

            switch (eventName) {
                case Freshchat.FRESHCHAT_USER_RESTORE_ID_GENERATED:
                    channel.invokeMethod(FRESHCHAT_USER_RESTORE_ID_GENERATED, true);
                    break;
                case Freshchat.FRESHCHAT_EVENTS:
                    Event event = Freshchat.getEventFromBundle(intent.getExtras());
                    if (event != null) {
                        data.put("event_name", event.getEventName().getName());
                        HashMap propertiesMap = new HashMap<>();
                        if (event.getProperties() != null && event.getProperties().size() > 0) {
                            for (Event.Property property : event.getProperties().keySet()) {
                                propertiesMap.put(property.getName(), String.valueOf(event.getProperties().get(property)));
                            }
                        }
                        data.put("properties", propertiesMap);
                    }
                    channel.invokeMethod(FRESHCHAT_EVENTS, data);
                    break;
                case Freshchat.FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED:
                    channel.invokeMethod(FRESHCHAT_ACTION_MESSAGE_COUNT_CHANGED, true);
                    break;
                case Freshchat.FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES:
                    channel.invokeMethod(FRESHCHAT_SET_TOKEN_TO_REFRESH_DEVICE_PROPERTIES, data);
                    break;
                case Freshchat.FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED:
                    data.put("url", intent.getExtras().getString("FRESHCHAT_DEEPLINK"));
                    channel.invokeMethod(FRESHCHAT_ACTION_NOTIFICATION_INTERCEPTED, data);
                    break;
                default:
                    Log.e(ERROR_TAG, "Invalid Event received");
            }

        }

    }

}
