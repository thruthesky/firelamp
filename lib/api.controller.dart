part of 'firelamp.dart';

/// Bio table name on backend server datagbase.
const String BIO_TABLE = 'api_bio';

/// Error codes
const String ERROR_EMPTY_RESPONSE = 'ERROR_EMPTY_RESPONSE';

/// Api GetX Controller
///
/// TODO: publish it as package.
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

  PublishSubject translationChanges = PublishSubject();

  FirebaseDatabase get database => FirebaseDatabase.instance;

  String get id => user?.id;
  String get sessionId => user?.sessionId;
  String get primaryPhotoUrl => user?.profilePhotoUrl;
  String get fullName => user?.name;
  String get nickname => user?.nickname;
  bool get profileComplete =>
      loggedIn &&
      primaryPhotoUrl != null &&
      primaryPhotoUrl.isNotEmpty &&
      fullName != null &&
      fullName.isNotEmpty;

  bool get loggedIn => user != null && user.sessionId != null;
  bool get notLoggedIn => !loggedIn;

  BehaviorSubject<bool> firebaseInitialized =
      BehaviorSubject<bool>.seeded(false);

  Api() {
    print("--> Api() constructor");
  }
  @override
  void onInit() {
    print("--> Api::onInit()");
    super.onInit();

    GetStorage.init().then((b) {
      localStorage = GetStorage();

      /// Load user profile from localStorage.
      /// If the user has logged in previously, he will be auto logged in on next app running.
      /// [user] will be null if the user has not logged in previously.
      user = _loadUserProfile();
      // if (loggedIn) print('ApiUser logged in with cached profile: ${user.sessionId}');

      /// If user has logged in with localStorage data, refresh the user data from backend.
      if (loggedIn) {
        userProfile(sessionId);
      }

      authChanges.add(user);
    });

    authChanges.listen((user) async {
      print('authChanges');
    });
  }

  /// Initialization
  ///
  /// This must be called from the app to initialize [Api]
  ///
  /// This method initialize firebase and the translation.
  ///
  ///
  ///
  /// ```dart
  /// Api.init(apiUrl: apiUrl);
  /// Api.version().then((res) => print('Api.version(): $res'));
  /// ```
  Future<void> init({@required String apiUrl}) async {
    _apiUrl = apiUrl;
    await _initializeFirebase();
    _initTranslation();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      firebaseInitialized.add(true);
      print("App is connected to Firebase!");
    } catch (e) {
      print("Error: failed to connect to Firebase!");
    }
  }

  /// Load translations
  _initTranslation() {
    database
        .reference()
        .child('notifications/translation')
        .onValue
        .listen((event) {
      loadTranslations();
    });
    loadTranslations();
  }

  /// If the input [data] does not have `session_id` property, add it.
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
    print("url: $_apiUrl?$queryString");
  }

  Future<dynamic> request(Map<String, dynamic> data) async {
    data = _addSessionId(data);
    // final res = await dio.get(url, queryParameters: data);

    dynamic res;
    _printDebugUrl(data);
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
      print(
          'api.controller.dart ERROR: code: ${res.data['code']}, requested data:');
      print(data);
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

  userProfile(String sessionId) async {
    if (sessionId == null) return;
    final Map<String, dynamic> res =
        await request({'route': 'user.profile', 'session_id': sessionId});
    user = ApiUser.fromJson(res);
    update();
    return user;
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
      if (comment != null &&
          comment.commentId != null &&
          comment.commentId != '')
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

  Future<Map<dynamic, dynamic>> setFeaturedImage(
      ApiPost post, ApiFile file) async {
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
  Future<List<ApiPost>> getPosts(
      {String category, int limit = 20, int paged = 1, String author}) {
    return searchPost(
        category: category, limit: limit, paged: paged, author: author);
  }

  Future<ApiFile> uploadFile(
      {@required File file, Function onProgress, String postType}) async {
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
      print(
        'Can not load anymore: loading: ${forum.loading},'
        ' noMorePosts: ${forum.noMorePosts}',
      );
      return;
    }
    forum.loading = true;
    forum.render();

    print('Going to load pageNo: ${forum.pageNo}');
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

  updateToken(String token, {String topic = ''}) {
    return request(
        {'route': 'notification.updateToken', 'token': token, 'topic': topic});
  }

  sendMessageToTokens(
      {String tokens,
      String title,
      String body,
      Map<String, dynamic> data,
      String imageUrl}) {
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

  subscribeOrUnsubscribeTopic(String topic, bool subscribe) async {
    Map<String, dynamic> req = {
      'route': 'notification.topicSubscription',
      'topic': topic,
      'subscribe': subscribe ? "Y" : "N",
    };
    final res = await request(req);
    api.user.data[topic] = subscribe ? 'Y' : 'N';
    return res;
  }

  Future translationList() {
    return request({'route': 'translation.list', 'format': 'language-first'});
  }

  /// todo: [loadTranslations] may be called twice at start up. One from [onInit], the other from [onFirebaseReady].
  /// todo: make it one time call.
  loadTranslations() async {
    final res = await request(
        {'route': 'translation.list', 'format': 'language-first'});
    // print('loadTranslations() res: $res');

    translationChanges.add(res);
  }
}
