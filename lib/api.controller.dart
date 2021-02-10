part of 'firelamp.dart';

@Deprecated('No more bio table and bio related functionality.')

/// Bio table name on backend server datagbase.
const String BIO_TABLE = 'api_bio';

/// Error codes
const String ERROR_EMPTY_RESPONSE = 'ERROR_EMPTY_RESPONSE';

/// Api GetX Controller
///
///
/// [Api] is the Api class for commuting backend.
/// It extends `GetxController` to update when user information changes.
class Api extends GetxController {
  ApiUser user;

  /// [authChanges] is posted on user login or logout. (Not on profile reading or updating)
  ///
  /// When user is logged in, the parameter will have value of `ApiUser`, or null.
  BehaviorSubject<ApiUser> authChanges = BehaviorSubject.seeded(null);

  /// [errror] is posted on any error.
  // ignore: close_sinks
  PublishSubject<dynamic> error = PublishSubject();

  Prefix.Dio dio = Prefix.Dio();

  /// [_apiUrl] is the api url.
  String _apiUrl;

  GetStorage localStorage;

  /// [storageInitialized] will be posted on get storage is ready.
  /// After this, you can use [localStorage]
  BehaviorSubject<bool> storageInitialized = BehaviorSubject<bool>.seeded(false);

  /// When translation changes(from backend), [translationChanges] event is posted with translation data.
  PublishSubject<Map<String, dynamic>> translationChanges = PublishSubject();

  /// When settings changes(from backend), [settingChanges] is posted with settings.
  PublishSubject<Map<String, dynamic>> settingChanges = PublishSubject();

  /// [settings] is the settings that was develivered over [settingChanges] event.
  Map<String, dynamic> settings = {};

  FirebaseDatabase get database => FirebaseDatabase.instance;

  String get id => user?.id;
  String get sessionId => user?.sessionId;
  String get primaryPhotoUrl => user?.profilePhotoUrl;
  String get fullName => user?.name;
  String get nickname => user?.nickname;
  String get profilePhotoUrl => user?.profilePhotoUrl;
  String get md5 => user?.md5;
  bool get profileComplete =>
      loggedIn &&
      primaryPhotoUrl != null &&
      primaryPhotoUrl.isNotEmpty &&
      fullName != null &&
      fullName.isNotEmpty;

  bool get loggedIn => user != null && user.sessionId != null;
  bool get notLoggedIn => !loggedIn;

  /// [firebaseInitialized] will be posted with `true` when it is initialized.
  BehaviorSubject<bool> firebaseInitialized = BehaviorSubject<bool>.seeded(false);

  /// Firebase Messaging
  ///
  /// If [enableMessaging] is set to true, it will do push notification. By default true.
  bool enableMessaging;

  /// [token] is the push notification token.
  String token;

  /// Event handlers on perssion state changes. for iOS only.
  /// These event will be called when permission is denied or not determined.
  Function onNotificationPermissionDenied;
  Function onNotificationPermissionNotDetermined;

  /// [onForegroundMessage] will be posted when there is a foreground message.
  Function onForegroundMessage;
  Function onMessageOpenedFromTermiated;
  Function onMessageOpenedFromBackground;

  static Api _instance;
  static Api get instance {
    if (_instance == null) {
      _instance = Api._internal();
    }
    return _instance;
  }

  Api._internal() {
    // print('=> Api._internal()');
  }

  /// FireLamp Api init
  ///
  /// [onInit] does the basics like
  /// - initalizing `GetStorage` and
  /// - loading(checking) user login
  /// - if the user logged in, then reload profile from backend.
  ///
  /// Note that, if you need to chagne the settings, you can do it with [init] method.
  @override
  void onInit() {
    // print("--> Api::onInit()");
    super.onInit();

    GetStorage.init().then((b) {
      localStorage = GetStorage();
      storageInitialized.add(true);

      /// First, load user profile from localStorage if the user previouly logged in
      ///
      /// If the user has logged in previously, he will be auto logged in on next app running.
      /// [user] will be null if the user has not logged in previously.
      user = _loadUserProfile();
      // if (loggedIn) print('ApiUser logged in with cached profile: ${user.sessionId}');

      /// Get user profile from backend if the user previous logged in.
      /// If user has logged in with localStorage data, refresh the user data from backend.
      if (loggedIn) {
        userProfile(sessionId);
      }

      authChanges.add(user);
    });

    authChanges.listen((user) async {
      // print('authChanges');
    });
  }

  /// Initialization
  ///
  /// This must be called from the app to initialize FireLamp Api.
  /// This method initialize firebase related code, i18n text translation, and others.
  ///
  /// You can set all the settings with this [init].
  ///
  ///
  ///
  /// ```dart
  /// Api.init(apiUrl: apiUrl);
  /// Api.version().then((res) => print('Api.version(): $res'));
  /// ```
  Future<void> init({
    @required String apiUrl,
    bool enableMessaging = true,
    Function onNotificationPermissionDenied,
    Function onNotificationPermissionNotDetermined,
    Function onForegroundMessage,
    Function onMessageOpenedFromTermiated,
    Function onMessageOpenedFromBackground,
  }) async {
    if (enableMessaging) {
      assert(onForegroundMessage != null,
          'If [enableMessaging] is set to true, [onForegroundMessage] must be provided.');
      assert(onMessageOpenedFromTermiated != null);
      assert(onMessageOpenedFromBackground != null);
    }
    this.enableMessaging = enableMessaging;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;

    _apiUrl = apiUrl;
    await _initializeFirebase();
    if (enableMessaging) _initMessaging();
    _initTranslation();
    _initSettings();
  }

  /// Firebase Initialization
  ///
  /// ! This must done after [init] because [init] sets the backend url,
  /// ! and probably the codes that run right after firebase initialization needs to connect to backend.
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      firebaseInitialized.add(true);
      // print("App is connected to Firebase!");
    } catch (e) {
      // print("Error: failed to connect to Firebase!");
    }
  }

  /// Load app translations and listen changes.
  _initTranslation() {
    database.reference().child('notifications').child('translation').onValue.listen((event) {
      // print('_initTranslation:: updated');
      _loadTranslations();
    });
    _loadTranslations();
  }

  /// Load app global settings and listen changes.
  ///
  /// Logic
  ///  - When there is chnages on settings,
  ///  - Get the whole settings from backend
  ///  - Post `settingChanges` event with settings.
  _initSettings() {
    database.reference().child('notifications').child('settings').onValue.listen((event) {
      // print('_initSettings:: updated');
      _loadSettings();
    });
    _loadSettings();
  }

  /// If the input [data] does not have `session_id` property and the user had logged in,
  /// then add `session_id`.
  Map<String, dynamic> _addSessionId(Map<String, dynamic> data) {
    if (data['session_id'] != null) return data;
    if (notLoggedIn) return data;

    data['session_id'] = user.sessionId;

    return data;
  }

  // ignore: unused_element
  _printDebugUrl(data) {
    Map<String, dynamic> params = {};
    data.forEach((k, v) {
      if (v is int || v is double) v = v.toString();
      params[k] = v;
    });

    String queryString = Uri(queryParameters: params).query;
    print("_printDebugUrl: $_apiUrl?$queryString");
  }

  Future<dynamic> request(Map<String, dynamic> data) async {
    data = _addSessionId(data);
    // final res = await dio.get(url, queryParameters: data);

    dynamic res;
    try {
      res = await dio.post(_apiUrl, data: data);
    } catch (e) {
      _printDebugUrl(data);
      rethrow;
    }
    // print('-------------> result of: dio.post(url, data:data) --> result: $res');
    if (res.data == null) {
      throw ('Response.body is null. Backend might not an API server. Or, Backend URL is wrong.');
    }

    if (res.data is String || res.data['code'] == null) {
      throw (res.data);
    } else if (res.data['code'] != 0) {
      /// If there is error like "ERROR_", then it throws exception.
      // print('api.controller.dart ERROR: code: ${res.data['code']}, requested data:');
      // print(data);
      throw res.data['code'];
    }
    return res.data['data'];
  }

  /// Get version of backend api.
  ///
  /// ```dart
  /// Api.version().then((res) => print('Api.version(): $res'));
  /// ```
  Future<dynamic> version() {
    return request({'route': 'app.version'});
  }

  /// Query directly to database with SQL.
  /// ```dart
  /// final re = await api.query('bio', "profile_photo_apiUrl!='' ORDER BY updatedAt DESC LIMIT 15");
  /// ```
  Future query(String table, String where) {
    return request({
      'route': 'app.query',
      'table': table,
      'where': where,
    });
  }

  /// [data] will be saved as user property. You can save whatever but may need to update the ApiUser model accordingly.
  Future<ApiUser> register({
    @required String email,
    @required String pass,
    Map<String, dynamic> data,
  }) async {
    data['route'] = 'user.register';
    data['user_email'] = email;
    data['user_pass'] = pass;
    data['session_id'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    // print('res: $res');
    user = ApiUser.fromJson(res);
    // print('user: $user');

    await _saveUserProfile(user);

    update();
    return user;
  }

  Future<ApiUser> loginOrRegister({
    @required String email,
    @required String pass,
    Map<String, dynamic> data,
  }) async {
    if (data == null) data = {};
    data['route'] = 'user.loginOrRegister';
    data['user_email'] = email;
    data['user_pass'] = pass;
    data['session_id'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    // print(res);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    authChanges.add(user);
    update();
    return user;
  }

  _saveUserProfile(ApiUser user) async {
    await localStorage.write('user', user.toJson());
  }

  /// Returns null if the user has not logged in.
  ApiUser _loadUserProfile() {
    final json = localStorage.read('user');
    if (json == null) return null;
    return ApiUser.fromJson(json);
  }

  Future<ApiUser> login({
    @required String email,
    @required String pass,
  }) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'user.login';
    data['user_email'] = email;
    data['user_pass'] = pass;
    data['session_id'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    authChanges.add(user);
    update();
    return user;
  }

  logout() async {
    await localStorage.remove('user');
    user = null;
    authChanges.add(null);
    update();
  }

  /// Update user key/value on user meta (Not on wp_users table)
  Future<ApiUser> updateUserMeta(String key, String value) async {
    final Map<String, dynamic> data = {
      'route': 'user.profileUpdate',
      key: value,
    };
    final Map<String, dynamic> res = await request(data);
    user = ApiUser.fromJson(res);
    update();
    return user;
  }

  Future<ApiUser> updateProfile(String key, String value) async {
    return updateUserMeta(key, value);
  }

  /// User profile data
  ///
  /// * logic
  ///   - load user profile data
  ///   - update app
  ///   - return user
  Future<ApiUser> userProfile(String sessionId) async {
    if (sessionId == null) throw ERROR_EMPTY_SESSION_ID;
    final Map<String, dynamic> res =
        await request({'route': 'user.profile', 'session_id': sessionId});
    user = ApiUser.fromJson(res);
    update();
    return user;
  }

  /// Returns other user profile data.
  ///
  /// It only returns public informations like nickname, gender, ... Not private information like phone number, session_id.
  /// ! @todo cache it on memory, so, next time when it is called again, it will not get it from server.
  Future<ApiUser> otherUserProfile(String id) async {
    final Map<String, dynamic> res = await request({'route': 'user.otherProfile', 'id': id});
    user = ApiUser.fromJson(res);
    update();
    return user;
  }

  /// Refresh user profile
  ///
  /// It is a helper function of [userProfile].
  Future<ApiUser> refreshUserProfile() {
    return userProfile(sessionId);
  }

  Future<ApiPost> editPost({
    int id,
    String category,
    String title,
    String content,
    List<ApiFile> files,
    Map<String, dynamic> data,
  }) async {
    if (data == null) data = {};
    if (id != null) data['ID'] = id;
    data['route'] = 'forum.editPost';
    if (category != null) data['category'] = category;
    if (title != null) data['post_title'] = title;
    if (content != null) data['post_content'] = content;
    if (files != null) {
      Set ids = files.map((file) => file.id).toSet();
      data['files'] = ids.join(',');
    }
    final json = await request(data);
    return ApiPost.fromJson(json);
  }

  Future<ApiComment> editComment({
    content = '',
    List<ApiFile> files,
    @required ApiPost post,
    ApiComment parent,
    ApiComment comment,
  }) async {
    final data = {
      'route': 'forum.editComment',
      'comment_post_ID': post.id,
      if (comment != null && comment.commentId != null && comment.commentId != '')
        'comment_ID': comment.commentId,
      if (parent != null) 'comment_parent': parent.commentId,
      'comment_content': content ?? '',
    };
    if (files != null) {
      Set ids = files.map((file) => file.id).toSet();
      data['files'] = ids.join(',');
    }
    final json = await request(data);
    return ApiComment.fromJson(json);
  }

  Future<ApiPost> getPost(dynamic id) async {
    final json = await request({'route': 'forum.getPost', 'id': id});
    return ApiPost.fromJson(json);
  }

  Future<Map<dynamic, dynamic>> setFeaturedImage(ApiPost post, ApiFile file) async {
    final json = await request({
      'route': 'forum.setFeaturedImage',
      'ID': post.id,
      'featured_image_ID': file.id,
    });
    return json;
  }

  /// Deletes a post.
  ///
  /// [post] is the post to be deleted.
  /// After the post has been deleted, it will be removed from [forum]
  ///
  /// It returns deleted file id.
  Future<int> deletePost(ApiPost post, [ApiForum forum]) async {
    final dynamic data = await request({
      'route': 'forum.deletePost',
      'ID': post.id,
    });
    if (forum != null) {
      int i = forum.posts.indexWhere((p) => p.id == post.id);
      forum.posts.removeAt(i);
    }
    return data['ID'];
  }

  /// Deletes a comment.
  ///
  /// [comment] is the comment to be deleted.
  /// [post] is the post of the comment.
  ///
  /// It returns deleted file id.
  Future<int> deleteComment(ApiComment comment, ApiPost post) async {
    final dynamic data = await request({
      'route': 'forum.deleteComment',
      'comment_ID': comment.commentId,
    });
    int i = post.comments.indexWhere((c) => c.commentId == comment.commentId);
    post.comments.removeAt(i);
    return data['comment_ID'];
  }

  /// Get posts from backend.
  ///
  /// You can use this to display some posts from the forum category. You may use this for displaying
  /// latest posts.
  Future<List<ApiPost>> searchPost({
    String category,
    int limit = 20,
    int paged = 1,
    String author,
    String searchKey,
  }) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'forum.search';
    data['category_name'] = category;
    data['paged'] = paged;
    data['numberposts'] = limit;
    if (searchKey != null) data['s'] = searchKey;
    if (author != null) data['author'] = author;
    final jsonList = await request(data);

    List<ApiPost> _posts = [];
    for (int i = 0; i < jsonList.length; i++) {
      _posts.add(ApiPost.fromJson(jsonList[i]));
    }
    return _posts;
  }

  /// [getPosts] is an alias of [searchPosts]
  Future<List<ApiPost>> getPosts({String category, int limit = 20, int paged = 1, String author}) {
    return searchPost(category: category, limit: limit, paged: paged, author: author);
  }

  Future<ApiFile> uploadFile({@required File file, Function onProgress, String postType}) async {
    /// [Prefix] 를 쓰는 이유는 Dio 의 FromData 와 Flutter 의 기본 HTTP 와 충돌하기 때문이다.
    final formData = Prefix.FormData.fromMap({
      /// `route` 와 `session_id` 등 추가 파라메타 값을 전달 할 수 있다.
      'route': 'file.upload',
      'session_id': sessionId,
      if (postType != null) 'post_type': postType,

      /// 아래에서 `userfile` 이, `$_FILES[userfile]` 와 같이 들어간다.
      'userfile': await Prefix.MultipartFile.fromFile(
        file.path,

        /// `filename` 은 `$_FILES[userfile][name]` 와 같이 들어간다.
        filename: getFilenameFromPath(file.path),
      ),
    });

    final res = await dio.post(
      _apiUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (onProgress != null) onProgress(sent * 100 / total);
      },
    );
    if (res.data is String || res.data['code'] == null) {
      throw (res.data);
    } else if (res.data['code'] != 0) {
      throw res.data['code'];
    }
    return ApiFile.fromJson(res.data['data']);
  }

  /// Deletes a file.
  ///
  /// [id] is the file id to delete.
  /// [postOrComment] is a post or a comment that the file is attached to. The
  /// file will be removed from the `files` array after deletion.
  ///
  /// It returns deleted file id.
  Future<int> deleteFile(int id, {dynamic postOrComment}) async {
    final dynamic data = await request({
      'route': 'file.delete',
      'ID': id,
    });
    int i = postOrComment.files.indexWhere((file) => file.id == id);
    postOrComment.files.removeAt(i);
    return data['ID'];
  }

  /// Forum data model container
  ///
  /// App can list/view multiple forum category at the same time.
  /// That's why it manages the container for each category.
  Map<String, ApiForum> forumContainer = {};

  @Deprecated('user attachForum')
  ApiForum initForum({@required String category, @required Function render}) {
    forumContainer[category] = ApiForum(category: category, render: render);
    return forumContainer[category];
  }

  /// Put the forum setting into a container. The container manages different categories.
  /// An app may open many forum list page at once. For instance, a user opens qna forum,
  /// then, opens discussion forum. So, there are two forums. And this handles the two forums
  /// and its settings, posts, and other meta information nicely.
  /// Without this, the developer must handle it himself.
  ApiForum attachForum(ApiForum forum) {
    forumContainer[forum.category] = forum;
    return forumContainer[forum.category];
  }

  Future<void> fetchPosts({ApiForum forum, String category}) async {
    if (category != null) forum = forumContainer[category];
    if (forum.canLoad == false) {
      // print(
      //   'Can not load anymore: loading: ${forum.loading},'
      //   ' noMorePosts: ${forum.noMorePosts}',
      // );
      return;
    }
    forum.loading = true;
    forum.render();

    // print('Going to load pageNo: ${forum.pageNo}');
    List<ApiPost> _posts;
    _posts = await searchPost(
      category: forum.category,
      paged: forum.pageNo,
      limit: forum.limit,
      author: forum.author,
      searchKey: forum.searchKey,
    );

    // No more posts if it loads less than `forum.list` or even it loads 0 posts.
    if (_posts.length < forum.limit) {
      forum.noMorePosts = true;
      forum.loading = false;
    } else {
      forum.pageNo++;
    }

    // If keySearch is not null, remove existing posts from list.
    if (forum.searchKey != null) {
      forum.posts = [];
    }

    _posts.forEach((ApiPost p) {
      forum.posts.add(p);
    });

    forum.loading = false;
    forum.render();
  }

  /// Return true if there is no problem on user's profile or throws an error.
  Future<bool> checkUserProfile() async {
    // print("if ($hasName && $hasGener && $hasBirthday)");
    if (notLoggedIn) {
      throw 'LOGIN_FIRST';
    }
    return true;
  }

  /// Update login user's record of a table.
  Future appUpdate(String table, String field, String value) {
    return request({
      'route': 'app.update',
      'table': table,
      'field': field,
      'value': value,
    });
  }

  /// Get login user's record of a table.
  ///
  /// Possible errors: ERROR_APP_GET_NO_RECORD
  Future appGet(String table) {
    return request({'route': 'app.get', 'table': table});
  }

  recordFailurePurchase(Map<String, dynamic> data) {
    data['route'] = 'purchase.recordFailure';
    return request(data);
  }

  recordPendingPurchase(Map<String, dynamic> data) {
    data['route'] = 'purchase.recordPending';
    return request(data);
  }

  recordSuccessPurchase(Map<String, dynamic> data) {
    data['route'] = 'purchase.recordSuccess';
    return request(data);
  }

  getMyPurchases() {
    return request({'route': 'purchase.myPurchase'});
  }

  /// Save token to backend.
  ///
  /// `session_id` will be added if the user had logged in.
  Future updateToken(String token, {String topic = ''}) {
    return request({'route': 'notification.updateToken', 'token': token, 'topic': topic});
  }

  sendMessageToTokens(
      {String tokens, String title, String body, Map<String, dynamic> data, String imageUrl}) {
    Map<String, dynamic> req = {
      'route': 'notification.sendMessageToTokens',
      'tokens': tokens,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'imageUrl': imageUrl,
    };
    return request(req);
  }

  sendMessageToTopic(
      {String topic, String title, String body, Map<String, dynamic> data, String imageUrl}) {
    Map<String, dynamic> req = {
      'route': 'notification.sendMessageToTopic',
      'topic': topic,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'imageUrl': imageUrl,
    };
    return request(req);
  }

  sendMessageToUsers(
      {List<String> users,
      String subscription,
      String title,
      String body,
      Map<String, dynamic> data,
      String imageUrl}) {
    Map<String, dynamic> req = {
      'route': 'notification.sendMessageToUsers',
      'users': users,
      if (subscription != null) 'subscription': subscription,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'imageUrl': imageUrl,
    };
    return request(req);
  }

  subscribeTopic(String topic, [dynamic tokens]) {
    Map<String, dynamic> req = {
      'route': 'notification.subscribeTopic',
      'topic': topic,
      if (tokens != null) 'tokens': tokens,
    };
    return request(req);
  }

  unsubscribeTopic(String topic, [dynamic tokens]) {
    Map<String, dynamic> req = {
      'route': 'notification.unsubscribeTopic',
      'topic': topic,
      if (tokens != null) 'tokens': tokens,
    };
    return request(req);
  }

  subscribeOrUnsubscribeTopic(String topic) async {
    Map<String, dynamic> req = {
      'route': 'notification.topicSubscription',
      'topic': topic,
    };
    final res = await request(req);
    // api.user.data[topic] = subscribe ? 'Y' : 'N';
    return res;
  }

  Future translationList() {
    return request({'route': 'translation.list', 'format': 'language-first'});
  }

  /// todo: [loadTranslations] may be called twice at start up. One from [onInit], the other from [onFirebaseReady].
  /// todo: make it one time call.
  _loadTranslations() async {
    final res = await request({'route': 'translation.list', 'format': 'language-first'});
    // print('loadTranslations() res: $res');

    translationChanges.add(res);
  }

  /// loadSettings
  _loadSettings() async {
    // print('Update on APP SETTINGS');
    settings = await request({'route': 'app.settings'});
    settingChanges.add(settings);
  }

  /// Initialize Messaging
  _initMessaging() async {
    /// Permission request for iOS only. For Android, the permission is granted by default.
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // print('User granted permission: ${settings.authorizationStatus}');

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          break;
        case AuthorizationStatus.denied:
          if (onNotificationPermissionDenied != null) onNotificationPermissionDenied();
          break;
        case AuthorizationStatus.notDetermined:
          if (onNotificationPermissionNotDetermined != null)
            onNotificationPermissionNotDetermined();
          break;
        case AuthorizationStatus.provisional:
          break;
      }
    }

    // Handler, when app is on Foreground.
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Check if app is opened from terminated state and get message data.
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedFromTermiated(initialMessage);
    }

    // Check if the app is opened from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpenedFromBackground(message);
    });

    // Get the token each time the application loads and save it to database.
    token = await FirebaseMessaging.instance.getToken();
    // print('_initMessaging:: token: $token');
    _saveTokenToDatabase(token);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);

    // When ever user logs in, update the token with user Id.
    authChanges.listen((user) {
      if (user == null) return;
      // print('Saving token on user auth chagnes: $token');
      _saveTokenToDatabase(token);
    });
  }

  /// Save the token to backend.
  ///
  Future _saveTokenToDatabase(String token) {
    this.token = token;
    return updateToken(token);
  }

  /// -------------------------------------------------------------------------------
  ///
  ///     CHAT FUNCTIONALTY
  ///
  /// -------------------------------------------------------------------------------

  /// [talkingTo] is the other user's document key that the login user is talking to.
  String talkingTo;
  ApiUser otherUser;

  /// Returns login user's room list collection `/chat/my-room-list/my-uid` reference.
  DatabaseReference get myRoomList {
    return userRoomListRef(Api.instance.id);
  }

  /// Return the collection of messages of the room id.
  DatabaseReference messagesRef(String roomId) {
    return database.reference().child('chat/messages').child(roomId);
  }

  /// Returns my room list collection `/chat/rooms/{user-id}` reference.
  DatabaseReference userRoomListRef(String userId) {
    return database.reference().child('chat/rooms').child(userId);
  }

  /// Returns my room (that has last message of the room) document
  DatabaseReference userRoomRef(String userId, String roomId) {
    return userRoomListRef(userId).child(roomId);
  }

  /// Returns document reference of my room (that has last message of the room)
  /// `/chat/rooms/my-id/{roomId}`
  DatabaseReference myRoom(String roomId) {
    return myRoomList.child(roomId);
  }

  chatEnter({@required String userId}) async {
    otherUser = await Api.instance.otherUserProfile(userId);

    /// @todo create `chat/rooms/myId/otherId` if not exists.
    userRoomRef(md5, otherUser.md5).once().then((DataSnapshot snapshot) {
      print('userRoomRef($md5, ${otherUser.md5})');
      print(snapshot);
      if (snapshot.value == null) return;
    });

    /// @todo create `chat/rooms/otherId/myId` if not exists.
    // database
    //     .reference()
    //     .child('chat/rooms/${otherUser.md5}/$id')
    //     .once()
    //     .then((DataSnapshot snapshot) {
    //   print('chat/rooms/${otherUser.md5}/$id');
    //   if (snapshot.value == null) return;
    // });

    /// @todo send message to `chat/message/myId/otherId` with protocol roomCreated
    /// @todo send message to `chat/message/otherId/myId` with protocol roomCreated
    /// @todo update chat room `chat/rooms/myId/otherId`. increase newMessage and stamp.
    /// @todo update chat room `chat/rooms/otherId/myId`. increase newMessage and stamp.

    talkingTo = otherUser.md5;

    // print('I am talking to: $talkingTo');

    /// @todo send push notification
  }

  /// Send chat message to the users in the room
  ///
  /// [displayName] is the name that the sender will use. The default is
  /// `ff.user.displayName`.
  ///
  /// [photoURL] is the sender's photo url. Default is `ff.user.photoURL`.
  ///
  /// [type] is the type of the message. It can be `image` or `text` if string only.
  Future<Map<String, dynamic>> sendMessage({
    @required String text,
    Map<String, dynamic> extra,
    String url,
    String urlType,
  }) async {
    // if (displayName == null || displayName.trim() == '') {
    //   throw CHAT_DISPLAY_NAME_IS_EMPTY;
    // }

    Map<String, dynamic> message = {
      'senderUid': id,
      'text': text,

      // Time that this message(or last message) was created.
      'createdAt': ServerValue.timestamp,

      if (extra != null) ...extra,
    };

    await messagesRef(otherUser.data['roomId']).push().set(message);

    // userRoomRef(userId, chat.roomId)

    // // print(message);
    // message['newMessages'] = FieldValue.increment(1); // To increase, it must be an udpate.
    // List<Future<void>> messages = [];

    // /// Just incase there are duplicated UIDs.
    // List<String> newUsers = [...global.users.toSet()];

    // /// Send a message to all users in the room.
    // for (String uid in newUsers) {
    //   // print(chatUserRoomDoc(uid, info['id']).path);
    //   messages.add(userRoomDoc(uid, global.roomId).set(message, SetOptions(merge: true)));
    // }
    // // print('send messages to: ${messages.length}');
    // await Future.wait(messages);

    // // TODO: Sending notification should be handled outside of firechat.

    // // await __ff.sendNotification(
    // //   '$displayName send you message.',
    // //   text,
    // //   id: id,
    // //   screen: 'chatRoom',
    // //   topic: topic,
    // // );

    return message;
  }

  /// -------------------------------------------------------------------------------
  ///
  ///     EO CHAT FUNCTIONALTY
  ///
  /// -------------------------------------------------------------------------------
}
