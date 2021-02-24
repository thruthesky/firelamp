# FireLamp

A flutter package to support CMS(Content Management System) functionalities like user management, forum management, and more for building apps like social apps, shopping apps.

It is based on Firebase and LAMP stack.

## A story

We have been working on a flutter package to support the basic functionalities that every app needs.

We first worked on Firebase with LAMP(or LEMP) stack for a while and we decided to remove LAMP stack since it is a hassle to maintain two stacks.

After a couple of months, we had successfully built the first version of flutter package without LAMP stack named `fireflutter`. But we were not satisfied with the complex query on firestore. Then, without hesitate, we went back to LAMP stack with Firebase.

And here it is, `FireLamp`.

## Reference

### LAMP stack on Wordpress

- We have built the backend on Wordpress.
  - [sonub](https://github.com/thruthesky/sonub)

# Installation

- Add latest version into pubspec.yaml
- Set the Firebase settings on the project.

  - Add iOS `GoogleServices-info.plist` and Android `google-serfvices.json`.

- The instance of FireLamp `Api` is a signleton.

## Put WithcenterApi instance as GetX controller

- Put the instance as `GetX` controller as early as possible on the app start-up like below. Root screen page would be a good place.
  - And, intialize `Api` like below. `apiUrl` is the backend api url.

```dart
class _MainAppState extends State<MainApp> {
  final Api a = Get.put<Api>(Api.instance);

  @override
  void initState() {
    super.initState();
    a.init(apiUrl: 'https://flutterkorea.com/wp-content/themes/sonub/api/index.php');
    a.version().then((res) {
      // print('res: $res');
    });
    a.translationChanges.listen((trs) {
      // print('trs: $trs');
    });
  }
```

## Language Settings

- First, add `language codes` in `Info.plist` on iOS. For android, it work out of the box.

```xml
		<key>CFBundleLocalizations</key>
		<array>
			<string>en</string>
			<string>ch</string>
			<string>ja</string>
			<string>ko</string>
		</array>
```

- Then, code like below.

```dart

class _MainAppState extends State<MainApp> {
  final Api a = Get.put<Api>(api);

  @override
  void initState() {
    super.initState();
    a.init(apiUrl: 'https://flutterkorea.com/wp-content/themes/sonub/api/index.php');
    a.translationChanges.listen((trs) {
      updateTranslations(trs);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Locale(Get.deviceLocale.languageCode),
      translations: AppTranslations(),
      getPages: [
        /// ...
      ],
    );
  }
}
```

## User

### Display user login information

- with stream builder

```dart
StreamBuilder(
  stream: api.authChanges,
  builder: (_, snapshot) {
    if (snapshot.hasData)
      return Text('User nickname: ${api.nickname}');
    else
      return Text('loading...');
  },
),
```

- or with getx

```dart
GetBuilder<Api>(
  builder: (_) {
    if (api.loggedIn)
      return Text('Session Id: ${api.sessionId}\n'
          'User nickname: ${api.nickname}');
    else
      return Text('Not logged in');
  },
),
```

## Forum

- Example of Forum List

```dart
import 'package:dalgona/screens/forum/widgets/no_more_posts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dalgona/services/globals.dart';
import 'package:dalgona/widgets/app.end_drawer.dart';
import 'package:dalgona/widgets/spinner.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForumListScreen extends StatefulWidget {
  ForumListScreen({Key key}) : super(key: key);

  @override
  _ForumListScreenState createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  /// Declare forum model(setting)
  ApiForum forum;
  @override
  void initState() {
    super.initState();

    /// Initialize the forum model
    forum = ApiForum(
      category: Get.arguments['category'],
      render: () {
        // print("no of posts: ${forum.posts.length}");
        setState(() => null);
      },
    );

    /// Attach the forum model to the api controller and let the controller handle
    /// all the forum settings.
    api.attachForum(forum);

    /// Load the first page
    api.fetchPosts(forum: forum).catchError((e) => app.error(e));

    /// Load next page on user scroll
    forum.itemPositionsListener.itemPositions.addListener(() {
      int lastVisibleIndex = forum.itemPositionsListener.itemPositions.value.last.index;
      if (forum.loading) return;
      if (lastVisibleIndex > forum.posts.length - 4) {
        api.fetchPosts(forum: forum).catchError((e) => app.error(e));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum list'),
      ),
      endDrawer: AppEndDrawer(),
      body: Column(
        children: [
          Expanded(
            /// Use ScrollablePositinoList instead of ListView.
            /// It can scroll by the item(post).
            child: ScrollablePositionedList.builder(
              itemScrollController: forum.listController,
              itemPositionsListener: forum.itemPositionsListener,
              itemCount: forum.posts.length,
              itemBuilder: (_, i) {
                ApiPost post = forum.posts[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'title: ${post.postTitle}',
                      style: TextStyle(fontSize: 34),
                    ),
                    RaisedButton(child: Text('Button'), onPressed: () {}),
                  ],
                );
              },
            ),
          ),
          Spinner(loading: forum.loading),
          NoMorePosts(forum: forum),
        ],
      ),
    );
  }
}
```

# Push Notification

- When user login, the app sends push token to backend and update it on backend.

  - Case - when user chagne, the token is updated on backend.

- When user register, the app send token to backend.

- When app is started(restarted), the app updates token to backend with session id if the user logged in.

# Chat

- Chat functionality is built on Firebae Realtime Database.
- Chat functionality can be used as a simple memo or message delivery in the app.

## Chat Structure and Security Rules

```
/// Chat
match /chat {
  /rooms {
    /UserA/UserB/ { newMessages: 0, timestamp: ..., }
    /UserA/UserC/ { newMessages: 0, timestamp: ..., }
  }
  /messages {
    /UserA {
      /UserB/ { ... chat messages documents .... }
      /UserC/ { ... chat messages documents .... }
    },
    /UserB {
      /UserA/ { .... chat messages .... }
    }
  }
}
```

- md5(`session_id`) is used as user identity called `userKey`
- Warning: do not save session_id. Save wordpress user_ID instead.
- User A's room list is under `/chat/UserA` where `UserA` is the `userKey`.
- If UserA had a chat with UserB, all chat messages will be saved under

  - Not only `/chat/messages/UserA/UserB` - save chat message
  - But also `/chat/messages/UserB/UserA` - save chat message
  - And also UPDATE `/chat/rooms/UserA/UserB` - update stamp of last chat message and increase newMessages.
  - And also UPDATE `/chat/rooms/UserB/UserA` - update stamp of last chat message and increase newMessages.

    That means, when UserA chats to UserB, the chat message will be saved under bother UserA and UserB.
    So, they can see each other's message.

- chat message document properties

  - sender: who sent. sender's wordpress user.ID.
  - timestamp: auto generated by database.
  - text: the chat message
  - photoUrl: if a photo was sent. it needs to display the photo.
  - protocol: chat event like 'roomCreate', 'enter', 'leave'.

- When displaying user information like nickname, profile photo, the data will come from backend and cached.
