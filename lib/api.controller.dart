part of 'withcenter.dart';

/// Bio table name on backend server datagbase.
const String BIO_TABLE = 'api_bio';

/// Error codes
const String ERROR_EMPTY_RESPONSE = 'ERROR_EMPTY_RESPONSE';

/// Forum model
///
/// [Forum] is a data model for a forum category.
///
/// Note that forum data model must not connect to backend directly by using API controller. Instead, the API controller
/// will use the instance of this forum model.
///
/// [Forum] only manages the data of a category.
class Forum {
  String category;
  List<ApiPost> posts = [];
  bool loading = false;
  bool noMorePosts = false;
  int pageNo = 1;
  int limit = 10;
  bool get canLoad => loading == false && noMorePosts == false;
  bool get canList => postInEdit == null && posts.length > 0;
  final ItemScrollController listController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  Function render;

  ApiPost postInEdit;
  Forum({@required this.category, this.limit = 10, @required this.render});

  /// Edit post or comment
  ///
  /// To create a post
  /// ```
  /// edit(post: ApiPost())
  /// ```
  ///
  /// To update a post
  /// ```
  /// edit(post: post);
  /// ```
  ///
  /// To cancel editing post
  /// ```
  /// edit(null)
  /// ```
  editPost(ApiPost post) {
    postInEdit = post;
    render();
  }

  /// Inserts a new post on top or updates an existing post.
  ///
  /// Logic
  /// - find existing post and replace. Or add new one on top.
  /// - render the view
  /// - scroll to the post
  insertOrUpdatePost(post) {
    postInEdit = null;
    int i = posts.indexWhere((p) => p.id == post.id);
    int jumpTo = 0;
    if (i == -1) {
      posts.insert(0, post);
    } else {
      posts[i] = post;
      jumpTo = i;
    }
    render();
    WidgetsBinding.instance.addPostFrameCallback((x) {
      listController.jumpTo(index: jumpTo);
    });
  }
}

/// WithcenterApi GetX Controller
///
/// TODO: publish it as package.
///
/// [WithcenterApi] is the Api class for commuting backend.
/// It extends `GetxController` to update when user information changes.
class WithcenterApi extends GetxController {
  ApiUser user;

  /// [authChanges] is posted on user login or logout. (Not on profile reading or updating)
  ///
  /// When user is logged in, the parameter will have value of `ApiUser`, or null.
  BehaviorSubject<ApiUser> authChanges = BehaviorSubject.seeded(null);

  /// [errror] is posted on any error.
  PublishSubject<dynamic> error = PublishSubject();

  Prefix.Dio dio = Prefix.Dio();

  /// [_apiUrl] is the api url.
  String _apiUrl;

  GetStorage localStorage;

  ApiBio bioData;

  /// [location] is the location package
  Location location = Location();

  /// Location 이 사용가능한 상태이면, 내 위치를 [myLocation] 에 보관한다. [locationReady] 가 true 인 상태에서 이 값에는 나의 최신 위치 정보가 들어가 있다.
  LocationData myLocation;
  bool serviceEnabled = false;
  bool permissionGranted = false;
  PermissionStatus _permissionGranted;

  /// Location(내 위치) 서비스가 Enable 되었고, 앱에 권한이 있으면 true
  bool get locationReady => serviceEnabled && permissionGranted;

  /// 이 이벤트가 false 값으로 전달되는 경우, serviceEnabled 또는 permissionGranted 를 참고해서,
  /// 서비스가 Enable 되지 않았는지 또는 앱 권한이 없는지 확인 할 수 있다.
  /// 참고로 앱이 부팅 할 때, 처음에는 null 이벤트가 발생하며, 그 이후, Location 기능이 사용가능하면 true, 아니면 false 가 한번 발생하게 된다.
  ///
  /// 예제)
  /// ```
  /// api.locationChanges.listen((re) async {
  ///   if (re == null) return;
  ///   /* 여기에 코드가 오면, Location 이 사용 가능한지 아닌지 확인된상태이다. */
  ///   await fetchUsers();
  /// });
  /// ```
  BehaviorSubject<bool> locationChanges = BehaviorSubject.seeded(null);

  PublishSubject translationChanges = PublishSubject();

  FirebaseDatabase get database => FirebaseDatabase.instance;

  String get id => user?.id;
  String get sessionId => user?.sessionId;
  String get primaryPhotoUrl => user?.profilePhotoUrl;
  String get fullName => user?.name;
  bool get profileComplete =>
      loggedIn &&
      primaryPhotoUrl != null &&
      primaryPhotoUrl.isNotEmpty &&
      fullName != null &&
      fullName.isNotEmpty;

  bool get loggedIn => user != null && user.sessionId != null;
  bool get notLoggedIn => !loggedIn;

  @override
  void onInit() {
    super.onInit();

    initLocation();
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
      if (user == null) {
        bioData = null;
      } else {
        try {
          bioData = await getMyBioRecord();
          update();
        } catch (e) {
          if (e == ERROR_EMPTY_RESPONSE) {
            bioData = ApiBio.fromJson({});
            print("bio data: $bioData");
          } else {
            error.add(e);
          }
        }
      }
    });
  }

  /// Sets the backend API URL
  /// ```dart
  /// withcenterApi.init(apiUrl: apiUrl);
  /// withcenterApi.version().then((res) => print('withcenterApi.version(): $res'));
  /// ```
  init({@required String apiUrl}) {
    _apiUrl = apiUrl;

    initTranslation();
    initLocation();
  }

  initTranslation() {
    database.reference().child('notifications/translation').onValue.listen((event) {
      loadTranslations();
    });
    loadTranslations();
  }

  initLocation() {
    checkLocation();
    listenLocationChange();
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

    // _printDebugUrl(data);
    final res = await dio.post(_apiUrl, data: data);
    // print('dio.post(url, data:data) --> result: $res');
    if (res.data == null) {
      throw ('Response.body is null. Backend might not an API server. Or, Backend URL is wrong.');
    }

    if (res.data is String || res.data['code'] == null) {
      throw (res.data);
    } else if (res.data['code'] != 0) {
      /// If there is error like "ERROR_", then it throws exception.
      print('api.controller.dart ERROR: code: ${res.data['code']}, requested data:');
      print(data);
      throw res.data['code'];
    }
    return res.data['data'];
  }

  /// Get version of backend api.
  ///
  /// ```dart
  /// withcenterApi.version().then((res) => print('withcenterApi.version(): $res'));
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
    data['route'] = 'user.loginOrRegister';
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
    final Map<String, dynamic> res = await request({'route': 'user.profile', 'session_id': sessionId});
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
  Future<int> deletePost(ApiPost post, [Forum forum]) async {
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

  Future<List<ApiPost>> searchPost({String category, int limit = 20, int paged = 1, String author}) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'forum.search';
    data['category_name'] = category;
    data['paged'] = paged;
    data['numberposts'] = limit;
    if (author != null) data['author'] = author;
    final jsonList = await request(data);

    List<ApiPost> _posts = [];
    for (int i = 0; i < jsonList.length; i++) {
      _posts.add(ApiPost.fromJson(jsonList[i]));
    }
    return _posts;
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
  Map<String, Forum> forumContainer = {};

  @Deprecated('user attachForum')
  Forum initForum({@required String category, @required Function render}) {
    forumContainer[category] = Forum(category: category, render: render);
    return forumContainer[category];
  }

  Forum attachForum(Forum forum) {
    forumContainer[forum.category] = forum;
    return forumContainer[forum.category];
  }

  fetchPosts({Forum forum, String category}) async {
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

    List<ApiPost> _posts;
    _posts = await searchPost(category: forum.category, paged: forum.pageNo, limit: forum.limit);

    if (_posts.length == 0) {
      forum.noMorePosts = true;
      forum.loading = false;
      forum.render();
      return;
    }

    forum.pageNo++;
    print('forum.pageNo: ${forum.pageNo}');

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

  updateToken(String token) {
    return request({'route': 'notification.updateToken', 'token': token});
  }

  sendMessageToTokens({String token, String title, String body, Map<String, dynamic> data, String imageUrl}) {
    Map<String, dynamic> req = {
      'route': 'notification.sendMessageToTokens',
      'token': token,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'imageUrl': imageUrl,
    };
    return request(req);
  }

  sendMessageToTopic({String topic, String title, String body, Map<String, dynamic> data, String imageUrl}) {
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

  Future translationList() {
    return request({'route': 'translation.list', 'format': 'language-first'});
  }

  Future<ApiBio> updateBio(String code, String value) async {
    final re = await appUpdate(BIO_TABLE, code, value);
    bioData = ApiBio.fromJson(re);
    update();
    return bioData;
  }

  Future<ApiBio> getMyBioRecord() async {
    final re = await appGet(BIO_TABLE);
    return ApiBio.fromJson(re);
  }

  /// 필요한 경우 언제든지 [checkLocation]을 호출해서, Location 기능이 사용가능한지 확인을 해 볼 수 있다.
  /// 예를 들어, Location 기능이 사용가능한지 아닌지에 따라서 동작을 달리해야 할 경우, [locationChanges] 이벤트를 listen 해도 되겠지만,
  /// 직접 `re = await checkLocation()` 와 같이 호출 해도 된다.
  Future<bool> checkLocation() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    if (serviceEnabled == false) {
      // location.serviceEnabled 와 같이 참조 가능
      locationChanges.add(locationReady);
      return false;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    if (_permissionGranted == PermissionStatus.granted) {
      permissionGranted = true;
    } else {
      permissionGranted = false;
      locationChanges.add(locationReady);
      return false;
    }

    // 나의 위치를 한번 읽는다.
    myLocation = await location.getLocation();

    // location.permissionGranted 와 같이 참조 가능
    locationChanges.add(locationReady);
    return locationReady;
  }

  /// 내 위치가 변경되는지 모니터링한다.
  ///
  /// 내 위치가 변경되면 서버 api_bio 테이블에 내 위치를 업데이트를 한다.
  listenLocationChange() async {
    /// [interval] 은 Android 에서만 동작한다. iOS 는 동작 안 함.
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 0.3);

    ///그래서, iOS 에서는 rxdart 로 12초에 한번씩 업데이트하도록 한다.
    location.onLocationChanged.throttleTime(Duration(milliseconds: 12345)).listen((LocationData data) async {
      if (notLoggedIn) return;
      myLocation = data;
      final params = {
        'route': 'app.updates',
        'table': BIO_TABLE,
        'latitude': data.latitude,
        'longitude': data.longitude,
        'accuracy': data.accuracy,
        'altitude': data.altitude,
        'speed': data.speed,
        'heading': data.heading,
        'time': data.time,
      };
      // print("api.location.controller.dart::listenLocationChange() $params");
      await request(params);
    });
  }

  /// todo: [loadTranslations] may be called twice at start up. One from [onInit], the other from [onFirebaseReady].
  /// todo: make it one time call.
  loadTranslations() async {
    final res = await request({'route': 'translation.list', 'format': 'language-first'});
    print('loadTranslations() res: $res');

    translationChanges.add(res);
  }
}
