## 0.10.9 (17/10/2023)
### Enhancement
* Improvements in user experience when loading messages in a conversation in Android.

### Bug fixes
* Fix for bot variables not being set for resolved conversations in Android.

## 0.10.9 (15/09/2023)
### Bug fixes
* Fix for a crash that occurs during "postback" flow in a bot conversation in Android.

## 0.10.8 (04/09/2023)
### Enhancement
* Handle disabling of reply editor when bot response is pending in Android.

### Bug fixes
* Fix file attachment not opening in Android.

## 0.10.7 (08/08/2023)
### Features
* Say hi to bot actions! Certain actions may need to be performed before or after the execution of a response in a bot conversation to complete the process. These changes can be anything in the chat screen, API triggers, pop-up feedbacks or articles, handover to agents, stop/Minimize conversations etc. You will be able to configure this via the bot builder using actions in iOS.
* We are adding support for multi-select as a new input type for your customers. Customers will now be able to pick and choose multiple choices that appears as buttons in Android.

### Enhancement
* Handle disabling of reply editor when bot response is pending in iOS.
* Improved displaying of last message in topic list with multiline text in iOS.
* Update UI for single select button in Android.

### Bug fixes
* Fix sporadic crash while setting user properties in iOS
* Fix triggering bot flow messages even when bot is unpublished in iOS.

## 0.10.6 (05/07/2023)
### Features
* Support for multi-select Carousel as a new input type for your customers. Customers will now be able to pick and choose multiple choices that appears as a series of options with a horizontal scroll (carousel) on the screen. The options list can also contain images in iOS.
* Support for Phone number and OTP as a new input type for your customers. Customers will now be able to enter their phone numbers with country code to generate an OTP which is then entered by user and is accepted by the SDK to process user information.
* You will now be able to pass custom user properties related to a user conversation from the mobile app to the bots via the SDK in Android.
* We are adding support for multi-select as a new input type for your customers. Customers will now be able to pick and choose multiple choices that appears as list and dropdown.
* We are adding support for Date and time as a new input type for your customers. Customers will now be able to pick a date and pick a time within the bot flow.
* Update UI for single select button and dropdown options.
* This version will now let you receive feedback from your customers in the form of a text. Customers will be able to type their feedback if configured in the bot flow in Android.
* This version will now let you receive feedback from your customers in the form of a preset choices. Customers will be able to choose their feedback from a maximum 3 choices in Android.
* This version will now let you receive feedback from your customers in the form of a star. Customers will be able to select the rating feedback if configured in the bot flow in Android.

### Bug Fixes :
* Fix for notifications not coming when an old user is restored over existing user in iOS.

## 0.10.5 (02/06/2023)
### Bug fixes
* Fix for app version not updating in device properties section (iOS)
* Fix profile image flickering for bot or agent message in chat (iOS)
* Fix for localization with country value (iOS)
* Fix display of CSAT title with theme color (iOS)
* Fix spaces in multiline bot messages with paragraph tag.

## 0.10.4 (09/05/2023)
### Feature
* Placeholder support for bot messages

### Enhancements
* Display links configured for bot articles
* Improve conversation fetch when user comes to chat without notification click (iOS)
* Update invalid initialization experience with alert message (iOS)

### Bug fixes
* Fix for displaying blank topic name in topic list screen (Android)
* Fix for multiple selection of quick reply buttons (Android)
* Fix for HTML tags not supported in carousel title and subtitle (Android)
* Fix for multiple selection of Dropdown options (Android)
* Fix for bot not being triggered when user responds to CSAT (Android)
* Fix for locale change not being reflected in topics screen (Android)
* Fix to show bot flow message instead of unsupported format error message (iOS)
* Fix to show HTML entities instead of entity names (iOS)
* Fix to allow attachments in the first message while talking to an agent. (iOS)
* Fix CFBundleSupportedPlatforms issue while submitting app to store (iOS)

## 0.10.3 (10/03/2023)

### Feature
* This version lets you receive star rate feedback from users during bot interactions (iOS)

### Bug fixes
* Fix to initiate bot for resolved conversations when chat screen opens (Android)
* Fix for send button being enabled when only empty spaces are entered (Android)
* Fix for extra space being displayed below multiline bot messages (Android)
* Fix for a crash which occurs while attaching images (Android)
* Fix for updating user details along with user creation (iOS)
* Fix to stop auto scrolling of Carousel cards to initial card (iOS)
* Fix for overlapping new message indicator with reply editor (iOS)
* Fix to allow sending attachment only when bot requests an attachment (iOS)
* Fix for localisation of FAQ search bar cancel text (iOS)
* Fix to stop FAQ content from shaking while scrolling with less content (iOS)

## 0.10.2 (22/12/2022)

### Bug fix
* Fix for FAQ configurations not working when no tags are provided.

## 0.10.1 (06/12/2022)

### Enhancement
* Changes to support Push notifications with P8 certification (iOS)

### Bug fix
* Fix for agent/bot message timestamp aligning to the right end of the message bubble (Android)

## 0.10.0 (23/11/2022)

### Feature
* This version lets you receive feedback (opinion polls & comments) from users during bot interactions (iOS)

### Enhancements
* Updated targetSdkVersion to Android 12 (Android)
* Minor UI changes and improvements to accomodate for ios devices and versions (iOS)

### Bug fixes
* Fix for Quick Action Pre-defined buttons (iOS)
* Fix impacting CSAT users for RTL users (iOS)
* Fix for the next bot flow to trigger on selecting carousel (Android)
* Fix for clearing error message for invalid input in bot flow (Android)
* Fix for handling empty messages (Android)
* Fix for handling quick actions menu overlapping in landscape mode (Android)
* Fix for custom attachment icons appearing too large in v0.9.9 (Android)

## 0.9.9 (20/10/2022)

### Features
* Bot will now be able to validate text in Mobile number, Email-ID and Number input types from customer in the conversation.
* Customer can upload file for bot flows and attachment option.

### Bug fixes
* Better handling of HTML content in messages (iOS)
* Allow encoded strings with quick actions and replies in messages (iOS)

## 0.9.8 (31/08/2022)

### Feature
* Support for read-only and single select carousel in bots flow (iOS)
* Support for quick options in bot flow

### Enhancements
* New device models added to track user devices (iOS)
* Redesign of "Powered by Freshworks" banner

### Bug fixes
* Theme fix for CSAT prompt (iOS)
* Display missing suggested article(s) in initial bot flow (iOS)
* Incorrect display of messages in a botflow (iOS)
* CFBundleExecutable error while uploading to AppStore (iOS)
* Display timestamp value for bot messages (iOS)
* Support for ```<li>,<ol>``` and ```<ul>``` html tags in messages (iOS)
* Update custom response expectation message with locale change (iOS)
* Add TOKEN_NOT_PROCESSED state for JWT auth users (iOS)
* Fix for ConnectivityManager leak (Android)

## 0.9.7 (23/03/2022)

### Enhancements
* Support for Dynamic Framework (iOS)

### Bug fixes
* Fixed unread message count listener (iOS)
* Package update for SPM (iOS)
* Fixed notification not being shown in the notification tray, when the app is in the background (Android)
* Fixed an issue with restoring a user using JWT (Android)
* Fixed an issue with sending APNS device token to Freshchat from Flutter
* Fixed an issue with toast message appearing when launching FAQs with options (Android)

## 0.9.6 (24/02/2022)

### Bug fixes
* Fix for dismissing keyboard when moving from Chat screen to App screen (Android)
* Fix for handing empty CSAT (Android)
* Fix FAQ article title override in search flow (iOS)
* Unread count overlap for topic list (iOS)
* Black navigation bar appearance on navigating via push notification (iOS)
* Rare invalid domain prompt during sdk initialization (iOS)
* Quick replies options support only for last message in a conversation (iOS)
* Sporadic crash while opening a chat when translation enabled (iOS)
* Crash on showFaq when either title or tags are null (iOS)
* Minor bug fixes (iOS)

## 0.9.5 (28/12/2021)

### Enhancement
* Ability to intercept notification clicks in Android
* Ability to listen to user interactions

### Bug fix
* Fix for displaying notifications in Android 12

## 0.9.4 (08/12/2021)

### Enhancement
* Optimise user create flow (iOS)

### Bug fix
* Fix for Topic name and image being empty

## 0.9.3 (24/11/2021)

### Enhancements
* Display complete name for messages created using API
* Support for fetching unread count for a specific channel using tags
* Resources path update and minor changes for other framework bundle (iOS)

### Bug Fix
* FAQ contactUs tags filter (iOS)

## 0.9.2 (08/11/2021)

### Bug Fix
* Fix CFBundleSupportedPlatforms issue while submitting app to store.

## 0.9.1 (03/11/2021)

### Bug Fix
* Fixed showConversations() crash in iOS

## 0.9.0 (28/10/2021)

### Enhancements
* Introducing self-service via bots on the SDK. Bots built using the Unified Bot Builder will now be accessible on the SDK too. Learn more about the capability [here](https://support.freshchat.com/en/support/solutions/articles/50000003778-bots-on-freshdesk-messaging-mobile-sdk).
* Toggle in init method for show/hide notification banner when app is in foreground - iOS

## 0.8.1 (07/08/2021)

### Bug Fix
* Fixed getUser() crash in iOS

## 0.8.0 (28/07/2021)

### Enhancements
* Added support for null safety
* Upgraded Freshchat iOS SDK version to 4.2.0

## 0.7.0 (19/06/2021)

### Enhancements
* Upgraded Freshchat Android SDK version to 4.3.5
* Upgraded Freshchat iOS SDK version to 4.1.8

### Breaking Change
* Changed getUserAlias method name to getFreshchatUserId

## 0.6.0 (24/05/2021)

### Bug Fix
* Fixed "Stream has already been listened to" error

## 0.5.0 (31/03/2021)

### Enhancements
* Android - Open Freshchat deeplink
* Android - Register for webview listener
* Android - Linkify for custom patterns
* Android - Runtime locale change support
* iOS - Config to enable/disable logging

### Bug Fix
* iOS - Made changes to support transitive dependencies

## 0.4.0 (25/03/2021)

### Enhancements
* Upgraded Freshchat Android SDK version to 4.3.3
* Upgraded Freshchat iOS SDK version to 4.1.6

### Bug Fix
* Handled null parameters in FreshchatUser object

## 0.3.1 (18/03/2021)

* Added missing changelogs

## 0.3.0 (18/03/2021)

### Enhancements
* iOS Theme specific config
* iOS localisation specific config

## 0.2.0 (11/03/2021)

### Enhancements
* Added external link handler
* Added unread message count change listener

## 0.1.0 (05/03/2021)

* Initial beta release of the Freshchat flutter SDK
