# FireLamp

A flutter package to support full CMS(Content Management System) functionalities like user management, forum management, and more for building apps like social & blog apps, shopping mall apps.

It is based on Firebase and LAMP stack.

## A story of Firelamp

We first worked on Firebase with LAMP(or LEMP) stack for a while and we decided to remove LAMP stack since it is a hassle to maintain two stacks.

After a couple of months, we had successfully built the first version of flutter package that work on Firebase alone without LAMP stack named `fireflutter`. But we were not satisfied with the complex query on firestore. Then, without hesitate, we went back to LAMP stack with Firebase.

And here it is, `FireLamp`.

We built our own PHP framework called [CenterX](https://github.com/thruthesky/centerx) to support firelamp.

# Installation

- Add latest version of [Firelamp](https://pub.dev/packages/firelamp) into pubspec.yaml

## CenterX Installation

- To use CenterX without Firebase, simply add the apiUrl.

```dart
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    Api.instance.init(apiUrl: 'https://itsuda50.com/index.php');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String version = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    try {
      version = (await Api.instance.version())['version'];
      setState(() {});
    } catch (e) {
      print('Api error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Firelamp: version: $version')
    );
  }
}
```

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

## Firebase Installation

- Set the Firebase settings on the project.

  - Add iOS `GoogleServices-info.plist` and Android `google-serfvices.json`.


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

## Api controller


- The instance of FireLamp `Api` is a signleton.

## App Settings

- When admin updates settings in admin page, `Api.instance.settings` will be automatically updated and [settingChanges] event will be posted.

```dart
final Api a = Get.put<Api>(api, permanent: true);
a.init(...);
a.settings = {'forum_like': 'Y', 'forum_dislike': 'Y', 'search_categories': ''};
a.settingChanges.listen((x) => setState(() {}));
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
                      'title: ${post.title}',
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

### 글 목록, 글 수정 예제

- 아래의 예제를 살펴보면, 글을 가져오고, 목록하고, 글 생성, 수정하는 방법을 잘 알 수 있다.

```dart
class _ProductInquiryScreenState extends State<ProductInquiryScreen> {
  String inquiryCategory = '';
  bool edit = false;
  ApiPost editPost;

  // 1. Forum 모델 정의(선언)
  ApiForum forum;

  @override
  void initState() {
    super.initState();

    // 2. Forum 모델 초기화
    forum = ApiForum(
      category: 'inquiry',
      render: () {
        if ( mounted ) setState(() => null);
      },
    );

    // 3. 첫 페이지 목록 가져오기
    () async {
      try {
        await api.fetchPosts(forum);
      } catch (e) {
        app.error(e);
      }
    }();

    // 4. 스크롤을 하면, 다음 페이지 글 목록 가져오기. 주의: 5 번에서 스크롤에 연결해야 함.
    forum.itemPositionsListener.itemPositions.addListener(() async {
      int lastVisibleIndex = forum.itemPositionsListener.itemPositions.value.last.index;
      if (forum.loading) return;
      if (lastVisibleIndex > forum.posts.length - 4) {
        try {
          await api.fetchPosts(forum);
        } catch (e) {
          app.error(e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RaisedButton(
          child: Text('문의 쓰기'),
          onPressed: () => setState(() => edit = true),
        ),
        if (edit) ...[
          ShoppingMallInquiryCategory(onChanged: (value) => this.inquiryCategory = value),
          ItsudaPostEdit(
            post: editPost,
            onCancel: () {
              // print('cancel:');
            },
            onError: (e) => error(e),
            onSubmit: (post) async {
              try {
                ApiPost edited = await api.postEdit(
                    post: post, categoryId: 'inquiry', subcategory: inquiryCategory);
                await alert('문의 사항을 등록하였습니다.');

                // 6. 글 작성 후 맨 위에 추가. 또는 글 수정 후, 해당 글 수정.
                if (editPost == null) {
                  // 글 작성이면 맨 위에 추가
                  forum.posts.insert(0, edited);
                } else {
                  // 글 수정이면, 아무것도 하지 않아도, Call by reference 로 원글이 이미 수정 되어 있다.
                  // 하지만, 아래와 같이, 수정된 글을 원본 글에 복사 해 주면 더 좋다.
                  int i = forum.posts.indexWhere((post) => post.idx == edited.idx);
                  forum.posts[i] = edited;
                  editPost = null;
                }
                // 수정 모드 해제 후, 화면 업데이트
                setState(() => edit = false);
              } catch (e) {
                error(e);
              }
            },
          ),
        ],
        // 5. 글 목록 표시. forum.listController 와 forum.itemPositionListener 연결.
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: forum.listController,
            itemPositionsListener: forum.itemPositionsListener,
            itemCount: forum.posts.length,
            itemBuilder: (_, i) {
              ApiPost post = forum.posts[i];
              return GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(top: md),
                  padding: EdgeInsets.all(md),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('title: ${post.title}', style: TextStyle(fontSize: 40)),
                      Text('content: ${post.content}', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                onTap: () {
                  // 7. 글을 터치하면, 수정
                  this.editPost = post;
                  this.edit = true;
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

# Forum settings

- You can get forum settings when you need. You may get forum settings from server on post list page.

- Or you can load the forum settings on `main.dart` like below before the app neends.

```dart
a.init(...);
ApiCategory qna = await api.categoryGet('qna');
ApiCategory reminder = await api.categoryGet('reminder');
ApiCategory discussion = await api.categoryGet('discussion');
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
