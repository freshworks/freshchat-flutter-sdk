---
name: Bug report
about: Create a report to help us improve Freshchat
title: 'Fix UI Issue for Freshchat SDK on Android 15 – Status Bar & Bottom Padding'
labels: 'Bug'
assignees: 'Freshchat Team'

---

## Describe the bug
I am using the latest Freshchat SDK (v0.10.23) in my Flutter project. The showChatConversation() method is working correctly on Android versions up to 14, but on Android 15, the Freshchat UI is displayed edge-to-edge without respecting the status bar color and bottom padding.

This issue affects the overall user experience, making the chat UI feel misaligned and inconsistent with the rest of the app.
Please check the screenshot attached for more detail.

## Steps to reproduce
```    
* Step 1 -Integrate freshchat_sdk: ^0.10.23 in a Flutter project.
* Step 2 - Call Freshchat.showChatConversation().
* Step 3 - Run the app on an Android 15 emulator or device.
* Step 4 - Observe that the chat UI extends edge-to-edge, removing status bar and bottom padding.
```

## Expected behavior
The chat UI should respect the status bar color and bottom insets, just like it does on Android 14 and below.

## Platform
- [ ] Android

- [ ] Flutter

## Freshchat SDK version
- SDK version : 0.10.23
- Flutter version (if applicable) : Flutter 3.19.2

## Device information
- [ ] it can be reproduce on every device which runs on android 15 and above andropid version

```
Provide device details here like
 * Device name pixel8
 * OS version android 15

```

## Crash log
if applicable, add logs here to help us debug the problem

## Screenshot/ Video recording 
![image](https://github.com/user-attachments/assets/366284e8-7698-4dcb-a4b0-e18b257d7da7)


## Additional context
Add any other context about the problem here.
