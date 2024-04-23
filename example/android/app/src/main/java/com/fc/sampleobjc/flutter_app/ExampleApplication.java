package com.fc.sampleobjc.flutter_app;

import com.freshchat.consumer.sdk.flutter.FreshchatSdkPlugin;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

public class ExampleApplication extends FlutterApplication {
//    @Override
    public void onCreate() {
//        super.onCreate();
//        This is not needed if the flutter version used is v1.12 and above
//        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
    }

//    @Override
    public void registerWith(PluginRegistry registry) {
//        This is not needed if the flutter version used is v1.12 and above
//        FlutterFirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FreshchatSdkPlugin.register(registry);
    }
}