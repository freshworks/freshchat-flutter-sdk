import 'dart:async';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:freshchat_sdk/freshchat_user.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //NOTE: Freshchat notification - Initialize Firebase for Android only.
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

enum FaqType { Categories, Articles }

void handleFreshchatNotification(Map<String, dynamic> message) async {
  if (await Freshchat.isFreshchatNotification(message)) {
    print("is Freshchat notification");
    Freshchat.handlePushNotification(message);
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print("Inside background handler");
  
  //NOTE: Freshchat notification - Initialize Firebase for Android only.
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }
  handleFreshchatNotification(message.data);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _userInfoKey = new GlobalKey<FormState>();
  final List<String> tags = ["vip"];
  String firstName = "",
      lastName = "",
      email = "",
      phoneCountryCode = "",
      phoneNumber = "",
      key = "",
      value = "",
      conversationTag = "",
      message = "",
      eventName = "",
      topicName = "",
      topicTags = "",
      jwtToken = "",
      freshchatUserId = "",
      userName = "",
      externalId = "",
      restoreId = "",
      jwtTokenStatus = "",
      obtainedRestoreId = "",
      sdkVersion = "",
      parallelConversationReferenceID1 = "",
      parallelConversationTopicName1 = "",
      parallelConversationReferenceID2 = "",
      parallelConversationTopicName2 = "";

  Map eventProperties = {}, unreadCountStatus = {};
  List<String> properties = [], topicTagsList = [];
  late FreshchatUser user;
  late StreamSubscription restoreStreamSubscription,
      fchatEventStreamSubscription,
      unreadCountSubscription,
      linkOpenerSubscription,
      notificationClickSubscription,
      userInteractionSubscription;

  void registerFcmToken() async {
    if (Platform.isAndroid) {
      String? token = await FirebaseMessaging.instance.getToken();
      print("FCM Token is generated $token");
      Freshchat.setPushRegistrationToken(token!);
    }
  }

  @override
  void initState() {
    super.initState();

    Freshchat.init(APPID, APPKEY, DOMAIN);
    Freshchat.linkifyWithPattern("google", "https://google.com");
    Freshchat.setNotificationConfig(
      notificationInterceptionEnabled: false,
      largeIcon: "large_icon",
      smallIcon: "small_icon",
    );

    //NOTE: Freshchat notification - Initialize Firebase for Android only.
    if (Platform.isAndroid) {
      registerFcmToken();

      FirebaseMessaging.instance.onTokenRefresh
          .listen(Freshchat.setPushRegistrationToken);
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var data = message.data;
        handleFreshchatNotification(data);
        print("Notification Content: $data");
      });

      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
    
    var restoreStream = Freshchat.onRestoreIdGenerated;
    restoreStreamSubscription = restoreStream.listen((event) async {
      print("Inside Restore stream: Restore Id generated");
      FreshchatUser user = await Freshchat.getUser;
      String? restoreId = user.getRestoreId();
      if (restoreId != null) {
        print("Restore Id: $restoreId");
        Clipboard.setData(new ClipboardData(text: restoreId));
      } else {
        restoreId = " ";
      }

      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: new Text("Restore ID copied: $restoreId")));
    });

    //NOTE: Freshchat events
    var userInteractionStream = Freshchat.onUserInteraction;
    userInteractionStream.listen((event) {
      print("User Interacted $event");
    });
    var notificationStream = Freshchat.onNotificationIntercept;
    notificationStream.listen((event) {
      print(" Notification: $event");
    });
    var freshchatEventStream = Freshchat.onFreshchatEvents;
    fchatEventStreamSubscription = freshchatEventStream.listen((event) {
      print("Freshchat Event: $event");
    });
    var unreadCountStream = Freshchat.onMessageCountUpdate;
    unreadCountSubscription = unreadCountStream.listen((event) {
      print("New message generated: " + event.toString());
    });
    var linkOpeningStream = Freshchat.onRegisterForOpeningLink;
    linkOpenerSubscription = linkOpeningStream.listen((event) {
      print("URL clicked: $event");
    });

    getSdkVersion();
    getFreshchatUserId();
    getTokenStatus();
    getUnreadCount();
    getUser();
  }

  void getUser() async {
    user = await Freshchat.getUser;
  }

  Future<String> getTokenStatus() async {
    JwtTokenStatus jwtStatus = await Freshchat.getUserIdTokenStatus;
    jwtTokenStatus = jwtStatus.toString();
    jwtTokenStatus = jwtTokenStatus.split('.').last;
    return jwtTokenStatus;
  }

  //NOTE: Platform messages are asynchronous, so we initialize in an async method.
  void getSdkVersion() async {
    sdkVersion = await Freshchat.getSdkVersion;
  }

  Future<String> getFreshchatUserId() async {
    freshchatUserId = await Freshchat.getFreshchatUserId;
    FlutterClipboard.copy(freshchatUserId);
    return freshchatUserId;
  }

  void getUnreadCount() async {
    unreadCountStatus = await Freshchat.getUnreadCountAsyncForTags(["tags"]);
  }

  void faqSearchTags(BuildContext context) {
    showDialog(context: context, builder: (context) => FaqTagAlert());
  }

  void getParallelConversationData(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "Parallel conversation data:",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                decoration: InputDecoration(labelText: "Reference ID 1"),
                initialValue: parallelConversationReferenceID1,
                onChanged: (val) {
                  setState(() {
                    parallelConversationReferenceID1 = val;
                  });
                }),
            TextFormField(
                decoration: InputDecoration(labelText: "Topic name 1"),
                initialValue: parallelConversationTopicName1,
                onChanged: (val) {
                  setState(() {
                    parallelConversationTopicName1 = val;
                  });
                }),
            TextFormField(
                decoration: InputDecoration(labelText: "Reference ID 2"),
                initialValue: parallelConversationReferenceID2,
                onChanged: (val) {
                  setState(() {
                    parallelConversationReferenceID2 = val;
                  });
                }),
            TextFormField(
                decoration: InputDecoration(labelText: "Topic name 2"),
                initialValue: parallelConversationTopicName2,
                onChanged: (val) {
                  setState(() {
                    parallelConversationTopicName2 = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "DONE",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void getUserInfo(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "User Details:",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "First Name",
                ),
                onChanged: (val) {
                  setState(() {
                    firstName = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Last Name",
                ),
                onChanged: (val) {
                  setState(() {
                    lastName = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Email",
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Phone Country Code",
                ),
                onChanged: (val) {
                  setState(() {
                    phoneCountryCode = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                ),
                onChanged: (val) {
                  setState(() {
                    phoneNumber = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "UPDATE USER",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  getUser();
                  user.setFirstName(firstName);
                  user.setEmail(email);
                  user.setPhone(phoneCountryCode, phoneNumber);
                  Freshchat.setUser(user);
                });
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "CANCEL",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void getUserProps(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "Custom User Properties:",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Key",
                ),
                onChanged: (val) {
                  setState(() {
                    key = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Value",
                ),
                onChanged: (val) {
                  setState(() {
                    value = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Add Properties",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Map map = {key: value};
                  Freshchat.setUserProperties(map);
                });
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void getTopicTags(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "Topic Tags",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Topic Name",
                ),
                onChanged: (val) {
                  setState(() {
                    topicName = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Topic Tags",
                ),
                onChanged: (val) {
                  setState(() {
                    topicTags = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Launch Topics",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(
                  () {
                    if (topicTags.contains(",")) {
                      topicTagsList = topicTags.split(",");
                    } else {
                      topicTagsList = [topicTags];
                    }
                    Freshchat.showConversations(
                        filteredViewTitle: topicName, tags: topicTagsList);
                  },
                );
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  Column addFeature(String name, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.lightBlueAccent,
          size: 30,
        ),
        Padding(padding: EdgeInsets.only(top: 10)),
        Text(
          '$name',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void setJwtToken(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "JWT Token",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "JWT Token",
                ),
                onChanged: (val) {
                  setState(() {
                    jwtToken = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          child: Wrap(
            children: <Widget>[
              MaterialButton(
                elevation: 10.0,
                child: Text(
                  "Set Token",
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () {
                  setState(
                    () {
                      Freshchat.setUserWithIdToken(jwtToken);
                    },
                  );
                },
              ),
              MaterialButton(
                elevation: 10.0,
                child: Text(
                  "Restore User",
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () {
                  setState(
                    () {
                      Freshchat.restoreUserWithIdToken(jwtToken);
                    },
                  );
                },
              ),
              MaterialButton(
                elevation: 10.0,
                child: Text(
                  "Token Status",
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () {
                  setState(
                    () {
                      getTokenStatus();
                      final snackBar = SnackBar(
                        content: Text("JWT Token Status: $jwtTokenStatus"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  );
                },
              ),
              MaterialButton(
                elevation: 10.0,
                child: Text(
                  "Cancel",
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.of(context, rootNavigator: true).pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void sendUserEvent(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "User Events",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Event Name",
                ),
                onChanged: (val) {
                  setState(() {
                    eventName = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "name1:value1,name2:value2,...",
                ),
                onChanged: (val) {
                  setState(() {
                    if (val.contains(",")) {
                      properties = val.toString().split(",");
                    } else {
                      properties.add(val.toString());
                    }
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Add Event",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(
                  () {
                    for (int i = 0; i < properties.length; i++) {
                      List values = properties[i].split(":");
                      if (values.length == 2) {
                        eventProperties[values[0]] = values[1];
                      }
                    }
                    Freshchat.trackEvent(eventName,
                        properties: eventProperties);
                  },
                );
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void restoreUser(BuildContext context) {
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "Identify/Restore User",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "External ID",
                ),
                onChanged: (val) {
                  setState(() {
                    externalId = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Restore ID",
                ),
                onChanged: (val) {
                  setState(() {
                    restoreId = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Identify/Restore",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(
                  () {
                    Freshchat.identifyUser(
                        externalId: externalId, restoreId: restoreId);
                    Navigator.of(context, rootNavigator: true).pop(context);
                    final snackBar = SnackBar(
                      content: Text("Copied Restore ID: $obtainedRestoreId"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                );
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void sendMessageApi(BuildContext context) {
    final _userInfoKey = new GlobalKey<FormState>();
    String? conversationTag, message;
    var alert = AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "Send Message API",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        key: _userInfoKey,
        child: Column(
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Conversation Tag",
                ),
                onChanged: (val) {
                  setState(() {
                    conversationTag = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Message",
                ),
                onChanged: (val) {
                  setState(() {
                    message = val;
                  });
                }),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Send Message",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(
                  () {
                    Freshchat.sendMessage(conversationTag!, message!);
                    Navigator.of(context, rootNavigator: true).pop(context);
                  },
                );
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Cancel",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  List<Column> features = [];

  @override
  Widget build(BuildContext context) {
    features = [];
    features.add(addFeature("FAQ", Icons.folder));
    features.add(addFeature("Set User Info", Icons.info));
    features.add(addFeature("Copy User Alias", Icons.contacts));
    features.add(addFeature("FAQ Tags", Icons.folder_special));
    features.add(addFeature("Reset User", Icons.delete));
    features.add(addFeature("Custom Props", Icons.add_circle));
    features.add(addFeature("SDK Version", Icons.developer_mode));
    features.add(addFeature("Send Message", Icons.send));
    features.add(addFeature("Add User Events", Icons.event));
    features.add(addFeature("Unread Count", Icons.markunread));
    features.add(addFeature("Topic Tags", Icons.list));
    features.add(addFeature("JWT Token", Icons.security));
    features.add(addFeature("Restore User", Icons.restore));
    features.add(addFeature("Stop Listeners", Icons.cancel));
    features.add(addFeature("Bot Variables", Icons.add_circle));
    features.add(addFeature("Update Parallel Conversation Data", Icons.info));
    features.add(addFeature("Show Parallel Conversation 1", Icons.chat));
    features.add(addFeature("Show Parallel Conversation 2", Icons.chat));
    features.add(addFeature("Dismiss Freshchat Screen", Icons.close_fullscreen));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Freshchat SDK'),
        ),
        body: Builder(
          builder: (context) => GridView.count(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 120),
            shrinkWrap: true,
            crossAxisCount: 3,
            children: List.generate(features.length, (index) {
              return GestureDetector(
                onTap: () {
                  switch (index) {
                    case 0:
                      Freshchat.showFAQ();
                      break;
                    case 1:
                      setState(() {
                        getUserInfo(context);
                      });
                      break;
                    case 2:
                      setState(() {
                        getFreshchatUserId();
                        final snackBar = SnackBar(
                          content: Text("User Alias: $freshchatUserId"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                      break;
                    case 3:
                      setState(() {
                        faqSearchTags(context);
                      });
                      break;
                    case 4:
                      Freshchat.resetUser();
                      Freshchat.init(APPID, APPKEY, DOMAIN,
                          themeName: "FCTheme.plist");
                      break;
                    case 5:
                      setState(() {
                        getUserProps(context);
                      });
                      break;
                    case 6:
                      setState(() {
                        getSdkVersion();
                        final snackBar = SnackBar(
                          content: Text("SDK Version: $sdkVersion"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                      break;
                    case 7:
                      setState(() {
                        sendMessageApi(context);
                      });
                      break;
                    case 8:
                      setState(() {
                        sendUserEvent(context);
                      });
                      break;
                    case 9:
                      setState(() {
                        getUnreadCount();
                        int count = unreadCountStatus['count'];
                        String status = unreadCountStatus['status'];
                        final snackBar = SnackBar(
                          content: Text(
                              "Unread Message Count: $count  Status: $status"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                      break;
                    case 10:
                      setState(() {
                        getTopicTags(context);
                      });
                      break;
                    case 11:
                      setState(() {
                        setJwtToken(context);
                      });
                      break;
                    case 12:
                      setState(() {
                        restoreUser(context);
                      });
                      break;
                    case 13:
                      setState(() {
                        restoreStreamSubscription.cancel();
                        fchatEventStreamSubscription.cancel();
                        unreadCountSubscription.cancel();
                        linkOpenerSubscription.cancel();
                      });
                      break;
                    case 14:
                      Map botVariables = {"Platform": "iOS"};
                      Map specificVariables = {
                        "2eaabcea-607a-417d-82f0-c9cef946d5dd": {
                          "SDKVersion": "1.2.3"
                        }
                      };
                      Freshchat.setBotVariables(
                          botVariables, specificVariables);
                      break;
                    case 15:
                      getParallelConversationData(context);
                      break;
                    case 16:
                      if (parallelConversationReferenceID1.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text("Conversation Reference ID 1 is empty.")));
                      } else {
                        Freshchat.showConversationWithReferenceID(parallelConversationReferenceID1, parallelConversationTopicName1);
                      }
                      break;
                    case 17:
                      if (parallelConversationReferenceID2.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text("Conversation Reference ID 2 is empty.")));
                      } else {
                        Freshchat.showConversationWithReferenceID(parallelConversationReferenceID2, parallelConversationTopicName2);
                      }
                      break;
                    case 18:
                      Freshchat.showConversations();
                      Future.delayed(Duration(seconds: 3), () {
                        Freshchat.dismissFreshchatView();
                      });
                  }
                },
                child: GridTile(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: features[index],
                  ),
                ),
              );
            }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.chat),
          onPressed: () {
            Freshchat.showConversations();
          },
        ),
      ),
    );
  }
}

class FaqTagAlert extends StatefulWidget {
  @override
  _FaqTagAlertState createState() => _FaqTagAlertState();
}

class _FaqTagAlertState extends State<FaqTagAlert> {
  List<String>? faqTagsList, contactUsTagsList;
  bool showContactUsOnFaqScreens = false,
      showFaqGrid = true,
      showContactUsOnAppBar = false,
      showContactUsOnFaqNotHelpful = true;
  FaqType faqType = FaqType.Categories;
  String? faqTitle, faqTag, contactUsTitle, contactUsTags;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        "FAQ Options:",
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'OpenSans-Regular'),
      ),
      content: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "FAQ Title",
                ),
                onChanged: (val) {
                  setState(() {
                    faqTitle = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "FAQ Tags",
                ),
                onChanged: (val) {
                  setState(() {
                    faqTag = val;
                  });
                }),
            ListTile(
              title: const Text('Categories'),
              leading: Radio(
                value: FaqType.Categories,
                groupValue: faqType,
                onChanged: (FaqType? val) {
                  setState(() {
                    faqType = val!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Articles'),
              leading: Radio(
                value: FaqType.Articles,
                groupValue: faqType,
                onChanged: (FaqType? val) {
                  setState(() {
                    faqType = val!;
                  });
                },
              ),
            ),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Contact Us Title",
                ),
                onChanged: (val) {
                  setState(() {
                    contactUsTitle = val;
                  });
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Contact Us Tags",
                ),
                onChanged: (val) {
                  setState(() {
                    contactUsTags = val;
                  });
                }),
            CheckboxListTile(
              title: Text("Show Contact Us on FAQ Screens"),
              value: showContactUsOnFaqScreens,
              onChanged: (bool? newValue) {
                setState(() {
                  showContactUsOnFaqScreens = newValue!;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
            CheckboxListTile(
              title: Text("Show FAQ Categories as Grid"),
              value: showFaqGrid,
              onChanged: (bool? newValue) {
                setState(() {
                  showFaqGrid = newValue!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text("Show Contact Us on App Bar"),
              onChanged: (bool? newValue) {
                setState(() {
                  showContactUsOnAppBar = newValue!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              value: false, //  <-- leading Checkbox
            ),
            CheckboxListTile(
              title: Text("Show Contact Us on FAQ not helpful"),
              value: showContactUsOnFaqNotHelpful,
              onChanged: (bool? newValue) {
                setState(() {
                  showContactUsOnFaqNotHelpful = newValue!;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "Launch FAQ",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  if (faqTag != null) {
                    if (faqTag!.contains(",")) {
                      faqTagsList = faqTag!.split(",");
                    } else {
                      faqTagsList = [faqTag!];
                    }
                  }
                  if (contactUsTags != null) {
                    if (contactUsTags!.contains(",")) {
                      contactUsTagsList = contactUsTags!.split(",");
                    } else {
                      contactUsTagsList = [contactUsTags!];
                    }
                  }
                  if (faqType == FaqType.Categories) {
                    print(
                        "FAQ category: $faqTitle, $contactUsTitle, $faqTagsList, $contactUsTagsList");
                    Freshchat.showFAQ(
                        faqTitle: faqTitle,
                        contactUsTitle: contactUsTitle,
                        faqTags: faqTagsList,
                        contactUsTags: contactUsTagsList,
                        faqFilterType: FaqFilterType.Category,
                        showContactUsOnFaqScreens: showContactUsOnFaqScreens,
                        showContactUsOnAppBar: showContactUsOnAppBar,
                        showContactUsOnFaqNotHelpful:
                            showContactUsOnFaqNotHelpful,
                        showFaqCategoriesAsGrid: showFaqGrid);
                  } else if (faqType == FaqType.Articles) {
                    print(
                        "FAQ article: $faqTitle, $contactUsTitle, $faqTagsList, $contactUsTagsList");
                    Freshchat.showFAQ(
                        faqTitle: faqTitle,
                        contactUsTitle: contactUsTitle,
                        faqTags: faqTagsList,
                        contactUsTags: contactUsTagsList,
                        faqFilterType: FaqFilterType.Article,
                        showContactUsOnFaqScreens: showContactUsOnFaqScreens,
                        showContactUsOnAppBar: showContactUsOnAppBar,
                        showContactUsOnFaqNotHelpful:
                            showContactUsOnFaqNotHelpful,
                        showFaqCategoriesAsGrid: showFaqGrid);
                  } else {
                    print(
                        "FAQ common: $faqTitle, $contactUsTitle, $faqTagsList, $contactUsTagsList");
                    Freshchat.showFAQ(
                        faqTitle: faqTitle,
                        contactUsTitle: contactUsTitle,
                        faqTags: faqTagsList,
                        contactUsTags: contactUsTagsList,
                        faqFilterType: FaqFilterType.Category,
                        showContactUsOnFaqScreens: showContactUsOnFaqScreens,
                        showContactUsOnAppBar: showContactUsOnAppBar,
                        showContactUsOnFaqNotHelpful:
                            showContactUsOnFaqNotHelpful,
                        showFaqCategoriesAsGrid: showFaqGrid);
                  }
                });
              },
            ),
            MaterialButton(
              elevation: 10.0,
              child: Text(
                "CANCEL",
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop(context);
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
