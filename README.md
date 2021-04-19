# FireLamp

A flutter package to support full CMS(Content Management System) functionalities like user management, forum management, and more for building apps like social & blog apps, shopping mall apps.

It is based on Firebase and LAMP stack.

## TODos

- API 전체를 재 작성.

  - Flutter 2.0 null safety 를 적용한다.
  - 웹 지원은 필요 없다.
  - library 이름을 지정하지 않는다. 자동 지정된다.
  - part, part of 를 사용하지 않고, mini library 를 사용한다.
  - 패키지 명칭을 `centerx` 로 변경하고, centerx 백엔드만 연결한다. 파이어베이스 연결은 하지 않는다.
  - lib/src 폴더를 활용하고, 외부에서 사용하게 할 것은 export 한다.
  - api.controller.dart 를 api.dart 로 변경
  - src/api.dart 에는 오직, CenterX 연결하는 코드만 넣는다.
  - Api.instance.authChanges 는 nullable 이다. 즉, null 이면, 최초 1회 event 가 발생하는 것이고, 캐시 로그인 정보가 없어도 ApiUser 객체를 리턴한다.

  - ApiForum 은 여러 게시판이 동시에 열려야하므로, GetX Controller 는 맞지 않다. 어떤 State manager 도 안된다.
    하지만, forum.render 가 여러가지로 문제가 많다. 특히, 플러터의 경우, 플랫폼 구조적인 문제로 인해, 처음 부터 로직이 잘못되면, 시간이 흐를 수록 더욱 많은 시간과 노력을 낭비하게 된다.
    그렇다고 RxDart 로 하기에는 subscribe 와 unsubscribe 가 너무 번거롭다.
    그래서, 글/코멘트 내용의 변화가 있으면, forum.addListeners() 와 같이 화면 랜더링을 처리를 한다. 여러개의 listener 를 추가 할 수 있도록 한다.

  - 그리고, 샘플 위젯을 코어로 포함시킨다.
    글 읽기 위젯에서, `nameBuilder:`, `avartarBuilder:`, `dateBuilder:`, `titleBilder:`, `contentBuilder:` 등 최대한의 옵션을 줄 수 있도록 한다.

  - 그리고 scrollable_positioned_list 사용을 기본으로 하지 말고 옵션으로 사용하기 쉽도록 해 준다.
    다른 list 위젯을 사용 할 수도 있고, single child scroll view 로 사용 할 수도 있다.
  - ApiForum() 클래스는 게시판의 전체적인 UI/UX 를 관리하는 컨트롤러이다.
    코멘트 읽기에서 버튼을 표시 할 때, builderCommentButtons: (ApiPost, ApiComment) { ... } 와 같이 처리를 할 수 있도록 한다.
    아래와 같이 게시판을 구성하는 모든 위젯을 커스터마이징 할 수도 있다.

  - `ApiPost` 에서 쇼핑몰 기능을 따로 빼 낸다. 시간이 없어서, `ApiPost` 에 쇼핑몰 속성을 집어 넣었는데, 완전히 빼야 한다.

  - 글 또는 코멘트에 공통적으로 쓰이는 메소드의 경우, `Article` 접두어 또는 접미어를 붙인다. 예. `reportArticle`. 그리고 이러한 함수는 리턴을 할 때, `ApiPost` 또는 `ApiComment` 둘 중 하나를 할 수 있다.

  - 웹 지원을 하지 않는다. 따라서 image compress 기능을 다시 firelamp 에 집어 넣는다.

```dart
ApiForum(
  builderPostMeta: (post) { return Rows(...); },
  builderPostTitle: (post) { return Text(post.title); },
  builderCommentButtons: () {},
  builderCommentContent: (comment) {
    return Text(comment.content);
  },
  onChatIconPressed: (ApiPost post, ApiComment comment) {
    app.openChatRoom(firebaseUid: comment.user.firebaseUid);
  },
);
```

- 게시판 위젯에 들어가는 모든 위젯을 micro 위젯으로 만들고, functional programming 을 해서, 재 사용가능하도록 한다.

- 관리자 페이지는 `centerx_admin` 패키지로 떼어낸다.
- firebase 를 연결하는 것은 `centerx_firebase` 패키지로 만든다.
- firechat 채팅은 현재 상태로 유지.
- 인앱결제는 `centerx_in_app_purchase` 로 변경한다.

## A story of Firelamp

We first worked on Firebase with LAMP(or LEMP) stack for a while and we decided to remove LAMP stack since it is a hassle to maintain two stacks.

After a couple of months, we had successfully built the first version of flutter package that work on Firebase alone without LAMP stack named `fireflutter`. But we were not satisfied with the complex query on firestore. Then, without hesitate, we went back to LAMP stack with Firebase.

And here it is, `FireLamp`.

We built our own PHP framework called [CenterX](https://github.com/thruthesky/centerx) to support firelamp.

# Installation

- Add latest version of [Firelamp](https://pub.dev/packages/firelamp) into pubspec.yaml

## CenterX Installation

- To use CenterX without Firebase, simply add the apiUrl to `Api.instance.init()`.
- Note that, you need to add `WidgetsFlutterBinding.ensureInitialized();` before calling `runApp()`. This is needed for using `SharedPreferences` in `Api` to load user information from local storage.

```dart
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return Scaffold(body: Center(child: Text('Firelamp: version: $version')));
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

## Developer Coding Guideline

- All the data value that comes from backend is a string.
  - For instance, user idx or post idx looks like a number. But when it is being used in flutter web, the parameta (on web) only accepts the key/value as string.

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

- Example of Forum List.
- You may copy the `PostList` widget and customize as you wish.

```dart
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/widgets/forum/post/post_list.dart';

class PostListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post list'),
      ),
      body: PostList(
        categoryId: 'qna',
        builder: (c, ApiPost post) {
          return ListTile(
            title: Text('${post.title}'),
          );
        },
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

## Forum changes

- 다음 버전에서 `render` 는 deprecated 될 것이다. 대신 `addListener` 를 사용한다.

```dart
ApiForum forum = ApiForum();
forum.addListener((ForumEvent event) {
  setState(() {});
});
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

# 관리자 페이지에서 사진 업로드 후, 사용자 페이지에 보여주기

- 아래에서, 사진을 업로드하고, `about` 에 저장한 다음, 사진의 파일 번호를 관리자 설정에 저장한다.

```dart
ApiFile about = ApiFile();
uploadAbout() async {
  try {
    about = await imageUpload(
      onProgress: (p) {
        about.percentage = p;
        update();
      },
      code: 'admin.app.about.setting',
      deletePreviousUpload: true,
    );
    about.percentage = 0;
    update();
    await api.setConfig('admin.app.about.setting', about.idx);
  } catch (e) {
    app.error(e);
  }
}
```

- 관리자 페이지에서는 아래와 같이 코딩을 한다.

```dart
class AdminAboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(),
      body: Container(
        child: GetBuilder<Admin>(
          builder: (_) => Column(
            children: [
              Row(
                children: [
                  ElevatedButton(onPressed: Admin.to.uploadAbout, child: Text('사진 등록')),
                ],
              ),
              _.about.percentage == 0
                  ? SizedBox.shrink()
                  : LinearProgressIndicator(value: _.about.percentage),
              CachedImage(_.about?.url ?? // 사진을 업로드했으면, 업로드한 사진을 보여준다.
                 // 아니면, 이미 업르된 사진을 보여준다. 여기서는 code 를 통해서 사진을 보여준다. 또는 아래 처럼, src 로 보여주어도 된다.
                 Api.instance.thumbnailUrl(code: 'admin.app.about.setting', original: true)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- 사용자 페이지에서는 아래와 같이 src 로 보여준다. thumbnailUrl 에서 code 로 보여주면 이미지 캐시가 되어서 관리자가 바꾼 사진이 안나타날 수 있다.

```dart
class IntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar('어플 소개'),
      endDrawer: AppEndDrawer(),
      body: SingleChildScrollView(
        child: Container(
          child: CachedImage(
              api.thumbnailUrl(src: api.settings['admin.app.about.setting'], original: true)),
        ),
      ),
    );
  }
}
```

# 글 목록 예제

- 아래는 글 작성, 수정, 삭제 등의 기능 없이, 글을 목록과 글 읽기 페이지를 보여주는 것만 있다.

```dart
import 'package:dalgona/screens/forum/no_posts_yet.dart';
import 'package:dalgona/screens/forum/post_more_buttons.dart';
import 'package:dalgona/screens/forum/post_slide_view.dart';
import 'package:dalgona/services/app.service.dart';
import 'package:dalgona/services/defines.dart';
import 'package:dalgona/services/globals.dart';
import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/no_more_posts.dart';
import 'package:firelamp/widgets/forum/post/post_preview.dart';
import 'package:firelamp/widgets/forum/post/post_view.dart';
import 'package:firelamp/widgets/forum/shared/vote_buttons.dart';
import 'package:firelamp/widgets/rounded_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// 글 목록과 읽기만 하는 위젯
///
/// 새 글 작성이나, 기존글 수정, 삭제 등을 하지 않는다. 즉, 글을 보여주기만을 위한 용도이며, 디자인을 마음데로 추가 할 수 있다.
class PostListView extends StatefulWidget {
  PostListView({this.categoryId});

  final String categoryId;

  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  /// Declare forum model(setting)
  ApiForum forum;

  loadPosts() async {
    try {
      await api.fetchPosts(forum);
      // Open(Show view page) if the post is on top to show.
      if (forum.postOnTop != null || forum.post != null) {
        forum.posts.first.display = true;
        forum.setting = app.categorySettings[forum.posts.first.categoryId];
      }
    } catch (e) {
      forum.loading = false;
      forum.render();
      app.error(e);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Initialize the forum model
    forum = ApiForum(
      categoryId: widget.categoryId,
      limit: 10,
      render: () {
        print("pageNo.: ${forum.pageNo}");
        setState(() => null);
      },
    );

    /// Load the first page.
    loadPosts();

    /// Load next page on user scroll.
    forum.itemPositionsListener.itemPositions.addListener(() {
      int lastVisibleIndex = forum.itemPositionsListener.itemPositions.value.last.index;
      if (forum.canLoad == false) return;
      if (lastVisibleIndex > forum.posts.length - 4) {
        loadPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Color(0xffebf0f7),
            child: forum.posts.isNotEmpty
                ? ScrollablePositionedList.builder(
                    itemScrollController: forum.listController,
                    itemPositionsListener: forum.itemPositionsListener,
                    itemCount: forum.posts.length,
                    itemBuilder: (_, i) {
                      ApiPost post = forum.posts[i];

                      return RoundedBox(
                        margin: EdgeInsets.all(Space.xs),
                        padding: EdgeInsets.all(Space.forumViewPadding),
                        boxColor: Colors.white,
                        radius: 10,
                        child: post.display
                            ? PostView(
                                forum: forum,
                                post: post,
                                onError: error,
                                actions: postActions(post),
                                onTitleTap: () => openPostView(post),
                              )
                            : PostPreview(
                                post,
                                forum,
                                onTap: () => openPostView(post),
                              ),
                      );
                    },
                  )
                : NoPostsYet(forum),
          ),
        ),

        if (forum.noMorePosts && !forum.noPosts) Center(child: NoMorePosts(forum: forum)),
        //  Loader
      ],
    );
  }

  postActions(ApiPost post) {
    return [
      VoteButtons(
        post,
        forum,
        onError: error,
      ),
      if (post.isNotMine) ...[
        SizedBox(width: xs),
        IconButton(
          icon: Icon(Icons.message_outlined, color: Color(0xff7d7d7d), size: 20),
          onPressed: () {
            print(post);
            app.openChatRoom(firebaseUid: post.user.firebaseUid);
          },
        ),
      ],
      Spacer(),
      PostMoreButtons(post, forum)
    ];
  }

  /// if [changeDisplay] is `false` it will not change the post display status
  ///   - for instance it will not close the post view status after editting.
  openPostView(ApiPost post) {
    if (post == null) return;
    if (forum.postView == 'slide') {
      /// Define controller for scrollView
      ScrollController _controller = ScrollController(
        initialScrollOffset: 0.0,
        keepScrollOffset: true,
      );

      showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) {
          return SingleChildScrollView(
            reverse: true,
            controller: _controller,
            child: PostSlideView(
              post,
              forum,
              actions: postActions(post),
            ),
          );
        },
      );

      /// Move to bottom of scroll Extent (top since the scroll view is reversed)
      SchedulerBinding.instance.addPostFrameCallback((_) => _controller.jumpTo(
            _controller.position.maxScrollExtent,
          ));
    } else {
      post.display = !post.display;
      setState(() {});
    }
  }
}
```

# 글과 Code 별 사진 등록

- 글에 사진을 표시 할 때, 사진의 code 에 따라 디자인을 다르게 보여주고자 할 때, 아래의 예제와 같이 글과 사진을 하면 된다.

- 아래 예제는 글에 사진을 등록 할 때, 광고 배너 사진, 광고 내용 사진을 등록하거나, 쇼핑몰에서 대표 사진, 설명 사진 등과 같이 각 사진의 용도가 정해져 있는 경우, code 값에 banner, content, primary, description 등의 code 를 주어서, 사진을 업로드한다.

- 그리고 사진을 변경하고자 하는 경우, 미리 삭제를 해서, 서버에 사용되지 않는 사진이남겨지는 일이 없도로 한다.

```dart
import 'package:dalgona/services/defines.dart';
import 'package:dalgona/services/globals.dart';
import 'package:firelamp/widgets/functions.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';

class EventForm extends StatefulWidget {
  EventForm(this.forum, {this.onSuccess, this.onError});

  final ApiForum forum;
  final Function onSuccess;
  final Function onError;

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final title = TextEditingController();
  final content = TextEditingController();
  double percentage = 0;
  bool loading = false;
  ApiPost post;

  InputDecoration roundBox = InputDecoration(
    filled: true,
    contentPadding: EdgeInsets.all(Space.sm),
    border: OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
  );

  onUploadImage(String code) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    try {
      final file = await imageUpload(
          quality: 95, onProgress: (p) => setState(() => percentage = p), code: code);
      percentage = 0;
      post.files.add(file);
      setState(() => null);
    } catch (e) {
      if (e != ERROR_IMAGE_NOT_SELECTED) {
        onError(e);
      }
    }
  }

  onFormSubmit() async {
    if (loading) return;
    setState(() => loading = true);

    if (Api.instance.notLoggedIn) return onError("login_first".tr);
    try {
      final editedPost = await Api.instance.postEdit(
          idx: post.idx,
          categoryId: widget.forum.categoryId,
          title: title.text,
          content: content.text,
          files: post.files);
      widget.forum.insertOrUpdatePost(editedPost);
      setState(() => loading = false);
      if (widget.onSuccess != null) widget.onSuccess(editedPost);
    } catch (e) {
      setState(() => loading = false);
      onError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    post = widget.forum.postInEdit ?? ApiPost();
    title.text = post.title;
    content.text = post.content;
  }

  @override
  Widget build(BuildContext context) {
    ApiForum forum = widget.forum;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(Space.sm),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
                padding: EdgeInsets.only(top: Space.xs, bottom: Space.xs), child: Text('이벤트 제목')),
            TextFormField(controller: title, decoration: roundBox),
            Padding(
                padding: EdgeInsets.only(top: Space.md, bottom: Space.xs),
                child: Text('이벤트 내용. 담첨자 목록 등.')),
            TextFormField(controller: content, minLines: 5, maxLines: 15, decoration: roundBox),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Submit button
                Row(
                  children: [
                    if (!loading)
                      TextButton(
                          child: Text('취소', style: TextStyle(color: Colors.red[300])),
                          onPressed: () {
                            forum.postInEdit = null;
                          }),
                    SizedBox(width: Space.xs),
                    TextButton(
                      child: loading
                          ? Spinner()
                          : Text('저장', style: TextStyle(color: Colors.green[300])),
                      onPressed: onFormSubmit,
                    ),
                  ],
                ),
              ],
            ),
            if (percentage > 0) LinearProgressIndicator(value: percentage),
            spaceSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CachedImage(bannerUrl),
                      bannerUrl == null
                          ? ElevatedButton(
                              child: Text('이벤트 배너 등록'),
                              onPressed: () => onUploadImage('banner'),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                try {
                                  await api.deleteFile(image('banner').idx, postOrComment: post);
                                  setState(() {});
                                } catch (e) {
                                  app.error(e);
                                }
                              },
                              child: Text('이벤트 배너 삭제')),
                    ],
                  ),
                ),
                spaceSm,
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CachedImage(contentUrl),
                      contentUrl == null
                          ? ElevatedButton(
                              child: Text('이벤트 내용 사진 등록'),
                              onPressed: () => onUploadImage('content'),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                try {
                                  await api.deleteFile(image('content').idx, postOrComment: post);
                                  setState(() {});
                                } catch (e) {
                                  app.error(e);
                                }
                              },
                              child: Text('이벤트 내용 사진 삭제')),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  onError(dynamic e) {
    app.error(e);
  }

  ApiFile image(String code) {
    if (this.post == null || this.post.files == null) return null;
    return this.post.files.firstWhere((f) => f.code == code, orElse: () => null);
  }

  String get bannerUrl {
    return image('banner')?.thumbnailUrl;
  }

  String get contentUrl {
    return image('content')?.thumbnailUrl;
  }
}
```

# 글 목록 예제

```dart
import 'package:dalgona/screens/forum/create_button_on_no_post.dart';
import 'package:dalgona/services/defines.dart';
import 'package:dalgona/services/globals.dart';
import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/forum/no_more_posts.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/material.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// 글 목록만 하는 위젯
///
/// 글 목록만 하고, 새 글 작성이나, 기존글 수정, 삭제 등을 하지 않는다. 즉, 글을 보여주기만을 위한 용도이며,
/// [builder] 를 통해 디자인(UI)을 마음데로 할 수 있다.
class PostListView extends StatefulWidget {
  PostListView({this.categoryId, @required this.builder});
  final String categoryId;
  final Function builder;
  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  /// 글 목록 설정 변수
  ApiForum forum;

  loadPosts() async {
    try {
      await api.fetchPosts(forum);
    } catch (e) {
      forum.loading = false;
      forum.render();
      app.error(e);
    }
  }

  @override
  void initState() {
    super.initState();

    /// 글 목록 설정. 스크롤을 아래로 하는 경우, 글이 4개 이하로 남으면, 다음 페이지 로드.
    forum = ApiForum(
      categoryId: widget.categoryId,
      limit: 10,
      render: () {
        print("pageNo.: ${forum.pageNo}");
        setState(() => null);
      },
      loadMoreOn: 4,
      loadMore: () => loadPosts(),
    );

    /// 첫 페이지 로드
    loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Color(0xffebf0f7),
            child: forum.posts.isNotEmpty
                ? ScrollablePositionedList.builder(
                    itemScrollController: forum.listController,
                    itemPositionsListener: forum.itemPositionsListener,
                    itemCount: forum.posts.length,
                    itemBuilder: (c, i) => widget.builder(c, forum.posts[i]),
                  )
                : CreateButtonOnNoPost(forum),
          ),
        ),
        if (forum.loading && forum.pageNo > 1) Spinner(padding: EdgeInsets.all(sm)),
        if (forum.noMorePosts && !forum.noPosts) Center(child: NoMorePosts(forum: forum)),
      ],
    );
  }
}
```

# Extensions

- See [app.translation.dart](https://github.com/thruthesky/dalgona/blob/main/lib/services/app.translations.dart) for how to update translation data.

- `String.t` extension to translate case-insenstively.

```dart
extension MyTrans on String {
  String get t {
    return this.toLowerCase().tr;
  }
}
```

# Widgets

## FirebaseReady

Show child widget only after firebase has initialized.

## UserReady

Show `login` child widget when user logged in. Or show `logout` widget.

# 친구 기능

- 친구 추가를 했는데, (또는 이미 친구인데), 친구 목록에 나오지 않는 다면, 차단된 경우 이다.
- 일방 차단인 경우, 쌍방 모두 대화를 할 수 없다.
