package com.fc.sampleobjc.flutter_app;

import com.freshchat.consumer.sdk.flutter.FreshchatSdkPlugin
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService

// This is not needed if the flutter version used is v1.12 and above

class ExampleApplicationKotlin : FlutterApplication(), PluginRegistrantCallback {
    @Override
    fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this)
    }
    @Override
    fun registerWith(registry: PluginRegistry) {
        FlutterFirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
        FreshchatSdkPlugin.register(registry)
    }
}