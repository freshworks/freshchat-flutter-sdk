import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'package:freshchat_sdk/freshchat_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freshchat Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Freshchat Flutter Demo'),
    );
  }
}

void handleFreshchatNotification(Map<String, dynamic> message) async {
  if (await Freshchat.isFreshchatNotification(message['data'])) {
    print("Handling Notification");
    Freshchat.handlePushNotification(message['data']);
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  handleFreshchatNotification(message);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  void initState() {
    super.initState();
    Freshchat.init("APP-ID",
        "APP-KEY", "DOMAIN",stringsBundle: "FCCustomLocalizable",themeName: "CustomTheme.plist");
    /**
     * This is the Firebase push notification server key for this sample app.
     * Please save this in your Freshchat account to test push notifications in Sample app.
     *
     * Server Key:
     * AAAAWQmY32o:APA91bF_X9S3rrfBLT5kUVaZ2uftEIpqALXu3z05SoTZhAikINhGmUsd62jQE374vgHLZyILA3lhsAxLJSQlivsZcK_yY_DAjdAQTesUpabs1_5XiRsonrWDm5envw24nQSPTDG81g1w
     *
     * Note: This is the push notification server key for sample app. You need to use your own server key for testing in your application
     */
    var restoreStream = Freshchat.onRestoreIdGenerated;
    var restoreStreamSubsctiption = restoreStream.listen((event) {
      print("Restore ID Generated: $event");
      notifyRestoreId(event);
    });
    if (Platform.isAndroid) {
      var tokenStream = firebaseMessaging.onTokenRefresh;
      tokenStream.listen((token) async {
        print("Token Set");
        Freshchat.setPushRegistrationToken(token);
      });
      firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            handleFreshchatNotification(message);
          },
          onBackgroundMessage: myBackgroundMessageHandler);
    }
  }

  void _incrementCounter() {
    setState(() {
      Freshchat.showConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(
          builder: (context) => GridView.count(
            crossAxisCount: 2,
            children: List.generate(6, (index) {
              switch (index) {
                case 0:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "FAQs",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () {
                        Freshchat.showFAQ(
                            showContactUsOnFaqScreens: true,
                            showContactUsOnAppBar: true,
                            showFaqCategoriesAsGrid: true,
                            showContactUsOnFaqNotHelpful: true);
                      });
                  break;
                case 1:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "Unread Count",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () async {
                        var unreadCountStatus =
                            await Freshchat.getUnreadCountAsync;
                        int count = unreadCountStatus['count'];
                        String status = unreadCountStatus['status'];
                        final snackBar = SnackBar(
                          content: Text(
                              "Unread Message Count: $count  Status: $status"),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      });
                  break;
                case 2:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "Reset User",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () {
                        Freshchat.resetUser();
                      });
                  break;
                case 3:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "Restore User",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () {
                        restoreUser(context);
                      });
                  break;
                case 4:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "Set User Properties",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () {
                        getUserProps(context);
                      });
                  break;
                case 5:
                  return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                            child: Text(
                              "Send Message",
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onTap: () {
                        sendMessageApi(context);
                      });
                  break;
                default:
                  return Center(
                    child: Text(
                      'Item $index',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  );
                  break;
              }
            }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Chat',
          child: Icon(Icons.chat),
        ),
      ),
    );
  }

  void restoreUser(BuildContext context) {
    var externalId, restoreId, obtainedRestoreId;
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

  void notifyRestoreId(var event) async{
    FreshchatUser user = await Freshchat.getUser;
    String restoreId = user.getRestoreId();
    Clipboard.setData(new ClipboardData(text: restoreId));
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Restore ID copied: $restoreId")));
  }

  void getUserProps(BuildContext context) {
    final _userInfoKey = new GlobalKey<FormState>();
    String key,value;
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

  void sendMessageApi(BuildContext context) {
    final _userInfoKey = new GlobalKey<FormState>();
    String conversationTag,message;
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
                    Freshchat.sendMessage(conversationTag, message);
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
}
