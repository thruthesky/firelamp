part of 'firelamp.dart';

/// Loading indicators.
class Loading {
  bool profile = false;
}

/// Api GetX Controller
///
///
/// [Api] is the Api class for commuting backend.
/// It extends `GetxController` to update when user information changes.
class Api {
  ApiUser user;
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  Loading loading = Loading();

  /// [authChanges] is posted on user login or logout. (Not on profile reading or updating)
  ///
  /// When user is logged in, the parameter will have value of `ApiUser`, or null.
  ///
  BehaviorSubject<ApiUser> authChanges = BehaviorSubject.seeded(null);

  /// The [profileChanges] is posted when user profile changed.
  ///
  /// Note that this event is posted not only for profile chages, but also user login/register. That is because
  /// `login()` and `register()` method takes user profile to change.
  /// More precisely, [profileChanges] event is posed on `_saveUserProfile` which is
  /// being called on profile chagnes and login, logout.
  BehaviorSubject<ApiUser> profileChanges = BehaviorSubject.seeded(null);

  /// [errror] is posted on any error.
  // ignore: close_sinks
  PublishSubject<dynamic> error = PublishSubject();

  Prefix.Dio dio = Prefix.Dio();

  /// [apiUrl] is the api url.
  String apiUrl;

  /// Translations
  ///
  /// Translation is enabled by default.
  /// When translation changes(from backend), [translationChanges] event is posted with translation data.
  PublishSubject<Map<String, dynamic>> translationChanges = PublishSubject();

  /// App Settings
  ///
  /// App Setting is enabled by default.
  /// When settings changes(from backend), [settingChanges] is posted with settings.
  PublishSubject<Map<String, dynamic>> settingChanges = PublishSubject();

  /// [settings] is the settings that was develivered over [settingChanges] event.
  ///
  Map<String, dynamic> settings = {};

  /// The [firestore] is Firestore database instance.
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Image compressor after taking Image.
  Function imageCompressor;

  @Deprecated('Use userIdx')
  int get idx => user == null ? 0 : user.idx;
  String get userIdx => user == null ? '0' : user.idx;
  String get sessionId => user?.sessionId;
  String get photoUrl => user?.photoUrl;
  String get fullName => user?.name;
  String get nickname => user?.nickname;
  bool get profileComplete =>
      loggedIn &&
      photoUrl != null &&
      photoUrl.isNotEmpty &&
      fullName != null &&
      fullName.isNotEmpty;

  bool get loggedIn => user != null && user.sessionId != null;
  bool get isAdmin => user != null && user.sessionId != null && user.admin == true;
  bool get notLoggedIn => !loggedIn;

  bool get isNewCommentOnMyPostOrComment {
    if (notLoggedIn) return false;
    return user.data[NEW_COMMENT_ON_MY_POST_OR_COMMENT] == null ||
        user.data[NEW_COMMENT_ON_MY_POST_OR_COMMENT] == 'on';
  }

  bool isSubscribeTopic(topic) {
    if (notLoggedIn) return false;
    return user.data[topic] != null && user.data[topic] == 'on';
  }

  bool isSubscribeChat(topic) {
    if (notLoggedIn) return false;
    return user.data[topic] == null || user.data[topic] == 'on';
  }

  /// To use firebase or not.
  bool enableFirebase;

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

  /// 쇼핑몰 카트
  ///
  /// 쇼핑몰은 [Cart] GetX 컨트롤러에 의해서 관리된다. `init` 함수 안에서 초기화된다. 따라서 `init` 의 동작이 끝난 다음,
  /// Get.put() 에 집어 넣어야 한다.
  ///
  Cart cart;

  /// Api Singleton
  static Api _instance;
  static Api get instance {
    if (_instance == null) {
      _instance ??= Api();
    }
    return _instance;
  }

  _initUserLogin() async {
    user = await _loadUserProfile();

    /// 로컬 캐시에 있는 데이터가 로드되는데로 한번 authChanges 가 호출된다.
    if (user != null) authChanges.add(user);
    if (user != null) {
      await userProfile(sessionId);
      authChanges.add(user);
    }
  }

  /// Initialization
  ///
  /// This must be called from the app to initialize FireLamp Api.
  /// This method initialize firebase related code, i18n text translation, and others.
  ///
  /// You can set all the settings with this [init].
  ///
  ///
  /// The [initUser] callback will be called after user login initialization.
  ///
  /// ```dart
  /// Api.init(apiUrl: apiUrl);
  /// Api.version().then((res) => print('Api.version(): $res'));
  /// ```
  Future<void> init({
    @required String apiUrl,
    bool enableFirebase = false,
    bool enableMessaging = false,
    Function onNotificationPermissionDenied,
    Function onNotificationPermissionNotDetermined,
    Function onForegroundMessage,
    Function onMessageOpenedFromTermiated,
    Function onMessageOpenedFromBackground,
    Function imageCompressor,
    Function initUser,
  }) async {
    if (enableMessaging) {
      assert(onForegroundMessage != null,
          'If [enableMessaging] is set to true, [onForegroundMessage] must be provided.');
      assert(onMessageOpenedFromTermiated != null);
      assert(onMessageOpenedFromBackground != null);
    }

    this.enableFirebase = enableFirebase;
    this.enableMessaging = enableMessaging;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;

    this.imageCompressor = imageCompressor;

    this.apiUrl = apiUrl;

    try {
      /// 주의: session id 가 잘못된 경우, exception 이 발생하는데, 그래도 이 함수의 나머지 코드는 실행되어야 한다.
      /// 그래서, try / catch block 을 사용한다.
      await _initUserLogin();
    } catch (e) {
      print('app.controller::init() _initUserLogin() throw an error: $e');
    }
    await _initializeFirebase();
    if (enableMessaging) _initMessaging();
    _initTranslation();
    _initSettings();

    _initFirebaseAuth();

    cart = Cart();
  }

  /// Automatic Firebase email/password login/logout.
  ///
  /// When user login or logout in firelamp, the app also login or logout into Firebase Auth automatically.
  /// Password is composed with `idx` and `createdAt` that are never changed. You may set the salt.
  _initFirebaseAuth() async {
    if (enableFirebase == false) return;
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        // print('User is currently signed out!');
      } else {
        // print('User is signed in! ${user.email}');
      }
    });

    authChanges.listen((user) async {
      // print(
      //     "_initFirebaseAuth() authChanges.listen((user) { ... }. user session id: ${user?.sessionId}");
      if (user == null) {
        await FirebaseAuth.instance.signOut();
      } else {
        String email = user.email;
        String password =
            user.email + user.idx + user.createdAt + ' Wc~7 difficult to guess string salt %^.^%;';

        // User email already exists(registered), try to login.
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          await userUpdateFirebaseUid(FirebaseAuth.instance.currentUser.uid);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');

            try {
              await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(email: user.email, password: password);
              await userUpdateFirebaseUid(FirebaseAuth.instance.currentUser.uid);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
              } else if (e.code == 'email-already-in-use') {}
            }
          } else if (e.code == 'wrong-password') {
            print('Firebase auth: Wrong password provided for that user. user: ${user.email}');
            alert('앗! 데이터베이스 로그인에 실패하였습니다. (에러코드: Firebase auth: wrong password)');
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  Future<void> userUpdateFirebaseUid(String uid) async {
    if (user.firebaseUid.isEmpty) {
      await userUpdate({FIREBASE_UID: FirebaseAuth.instance.currentUser.uid});
    }
  }

  /// Firebase Initialization
  ///
  /// ! This must done after [init] because [init] sets the backend url,
  /// ! and probably the codes that run right after firebase initialization needs to connect to backend.
  Future<void> _initializeFirebase() async {
    if (enableFirebase == false) return;
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
    if (enableFirebase == false) return;
    firestore
        .collection('notifications')
        .doc('translations')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      _loadTranslationFromCenterX();
    });
  }

  /// Load app global settings and listen changes.
  ///
  /// Logic
  ///  - When there is chnages on settings,
  ///  - Get the whole settings from backend
  ///  - Post `settingChanges` event with settings.
  _initSettings() {
    if (enableFirebase == false) return;
    firestore
        .collection('notifications')
        .doc('settings')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      _loadSettingFromCenterX();
    });
  }

  /// If the input [data] does not have `session_id` property and the user had logged in,
  /// then add `session_id`.
  Map<String, dynamic> _addSessionId(Map<String, dynamic> data) {
    if (data['sessionId'] != null) return data;
    if (notLoggedIn) return data;

    data['sessionId'] = user.sessionId;

    return data;
  }

  // ignore: unused_element
  _printDebugUrl(data) {
    Map<String, dynamic> params = {};
    data.forEach((k, v) {
      if (v is int || v is double) v = v.toString();
      params[k] = v;
    });

    try {
      String queryString = Uri(queryParameters: params).query;
      print("_printDebugUrl: $apiUrl?$queryString");
      debugPrint("_printDebugUrl: $apiUrl?$queryString", wrapWidth: 1024);
    } catch (e) {
      print("Caught error on _printDebug() with data: ");
      print(data);
    }
  }

  Future<dynamic> request(Map<String, dynamic> data) async {
    // print('request: $data');
    // _printDebugUrl(data);
    data = _addSessionId(data);
    // final res = await dio.get(url, queryParameters: data);

    dynamic res;
    try {
      // _printDebugUrl(data);
      res = await dio.post(apiUrl, data: data);
    } catch (e) {
      print('dio.post() got error; apiUrl: $apiUrl');
      print(e);
      _printDebugUrl(data);
      rethrow;
    }
    // print('-------------> result of: dio.post(url, data:data) --> result: $res');
    if (res.data == null) {
      throw ('Response.body is null. Backend might not an API server. Or, Backend URL is wrong.');
    }

    if (res.data is String) throw (res.data);

    dynamic response = res.data['response'];
    if (response is String && response.indexOf('error_') == 0) throw response;

    return response;

    // else if (res.data['code'] != 0) {
    //   /// If there is error like "ERROR_", then it throws exception.
    //   // print('api.controller.dart ERROR: code: ${res.data['code']}, requested data:');
    //   // print(data);
    //   throw res.data['code'];
    // }
    // return res.data['data'];
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
  /// final re = await api.query('bio', "profile_photoapiUrl!='' ORDER BY updatedAt DESC LIMIT 15");
  /// ```
  Future query(String table, String where) {
    return request({
      'route': 'app.query',
      'table': table,
      'where': where,
    });
  }

  /// Save user profile into storage.
  ///
  /// This method is being callled on user profile update(or change).
  /// Be sure that this method is being called on login & regsiter.
  _saveUserProfile(ApiUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profileChanges.add(user);
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  /// Returns null if the user has not logged in.
  Future<ApiUser> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user');
    if (user == null) return null;
    Map<String, dynamic> json = jsonDecode(user);
    return ApiUser.fromJson(json);
  }

  Future<ApiUser> login({
    @required String email,
    @required String password,
  }) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'user.login';
    data['email'] = email;
    data['password'] = password;
    data['sessionId'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    authChanges.add(user);

    return user;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    user = null;
    FirebaseAuth.instance.signOut();
    authChanges.add(null);
  }

  /// [data] will be saved as user property. You can save whatever but may need to update the ApiUser model accordingly.
  Future<ApiUser> register({
    @required String email,
    @required String password,
    Map<String, dynamic> data,
  }) async {
    if (data == null) data = {};
    data['route'] = 'user.register';
    data['email'] = email;
    data['password'] = password;
    data['sessionId'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    // print('res: $res');
    user = ApiUser.fromJson(res);
    // print('user: $user');

    await _saveUserProfile(user);
    authChanges.add(user);
    return user;
  }

  Future<ApiUser> loginOrRegister({
    @required String email,
    @required String pass,
    Map<String, dynamic> data,
  }) async {
    if (data == null) data = {};
    data['route'] = 'user.loginOrRegister';
    data['email'] = email;
    data['password'] = pass;
    data['sessionId'] = '';
    data['token'] = token;
    final Map<String, dynamic> res = await request(data);
    // print(res);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    authChanges.add(user);

    return user;
  }

  Future<ApiUser> userUpdate(Map<String, dynamic> data) async {
    data['route'] = 'user.update';
    final Map<String, dynamic> res = await request(data);
    user = ApiUser.fromJson(res);
    _saveUserProfile(user);
    return user;
  }

  /// Switch [option] to `on` and `off`.
  /// If [option] doesnt exist it switch to `on`.
  /// If [option] is `on` it switch to `off`.
  /// If [option] is `off` it switch to `on`.
  Future<ApiUser> userOptionSwitch({String option, String route = 'user.switch'}) async {
    Map<String, dynamic> req = {
      'route': route,
      'option': option,
    };
    final res = await request(req);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    return user;
  }

  /// it will always switch the [option]:`on`
  Future<ApiUser> userOptionSwitchOn(String option) async {
    return userOptionSwitch(option: option, route: 'user.switchOn');
  }

  /// it will always switch the [option]:`off`
  Future<ApiUser> userOptionSwitchOff(String option) async {
    return userOptionSwitch(option: option, route: 'user.switchOff');
  }

  /// User profile data
  ///
  /// * logic
  ///   - load user profile data
  ///   - update app
  ///   - return user
  Future<ApiUser> userProfile(String sessionId) async {
    if (sessionId == null) throw ERROR_EMPTY_SESSION_ID;
    loading.profile = true;
    final Map<String, dynamic> res =
        await request({'route': 'user.profile', 'sessionId': sessionId});
    user = ApiUser.fromJson(res);
    loading.profile = false;

    return user;
  }

  /// Returns other user profile data.
  ///
  /// It only returns public informations like nickname, gender, ... Not private information like phone number, session_id.
  /// ! @todo cache it on memory, so, next time when it is called again, it will not get same information from server.
  Future<ApiUser> otherUserProfile({String idx, String email, String firebaseUid}) async {
    final Map<String, dynamic> res = await request({
      'route': 'user.otherUserProfile',
      if (idx != null) 'idx': idx,
      if (email != null) 'email': email,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
    });
    ApiUser otherUser = ApiUser.fromJson(res);
    return otherUser;
  }

  /// Refresh user profile
  ///
  /// It is a helper function of [userProfile].
  Future<ApiUser> refreshUserProfile() {
    return userProfile(sessionId);
  }

  @Deprecated('user postEdit()')

  /// edit(create or update) post
  ///
  /// If [post] is given, the id, category, title, content and files will be used from it instead.
  /// [post] 에 값이 있으면, 그 값을 사용한다.
  Future<ApiPost> editPost({
    int id,
    String category,
    String title,
    String content,
    List<ApiFile> files,
    Map<String, dynamic> data,
    ApiPost post,
  }) async {
    if (data == null) data = {};
    data['route'] = 'forum.editPost';

    if (id != null) data['ID'] = id;
    if (category != null) data['category'] = category;
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (files != null) {
      Set ids = files.map((file) => file.idx).toSet();
      data['files'] = ids.join(',');
    }

    ///
    /// If [post] is given, the id, category, title, content and files will be used from it instead.
    /// [post] 에 값이 있으면, 그 값을 사용한다.
    if (post != null) {
      if (post.idx != null) data['ID'] = post.idx;
      if (post.categoryIdx != null) data['category'] = post.categoryIdx;
      if (post.title != null && post.title != '') data['title'] = post.title;
      if (post.content != null && post.content != '') data['content'] = post.content;
      if (post.files.length > 0) {
        Set ids = post.files.map((file) => file.idx).toSet();
        data['files'] = ids.join(',');
      }
    }

    final json = await request(data);
    return ApiPost.fromJson(json);
  }

  ///
  Future<ApiPost> postEdit({
    String idx,
    String relationIdx,
    String categoryId,
    String subcategory,
    String title,
    String content,
    List<ApiFile> files,
    String code,
    Map<String, dynamic> data,
    ApiPost post,
  }) async {
    if (data == null) data = {};

    if (idx == null && (post == null || post.idx == null)) {
      data['route'] = 'post.create';
    } else {
      data['route'] = 'post.update';
      data['idx'] = idx;
    }

    if (relationIdx != null) data['relationIdx'] = relationIdx;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (subcategory != null) data['subcategory'] = subcategory;
    if (files != null) {
      Set ids = files.map((file) => file.idx).toSet();
      data['files'] = ids.join(',');
    }
    if (code != null) data['code'] = code;

    ///
    if (post != null) {
      if (post.idx != null) data['idx'] = post.idx;
      if (post.relationIdx != null) data['relationIdx'] = post.relationIdx;
      if (post.categoryIdx != null) data['categoryIdx'] = post.categoryIdx;
      if (post.title != null && post.title != '') data['title'] = post.title;
      if (post.content != null && post.content != '') data['content'] = post.content;
      if (post.subcategory != null) data['subcategory'] = post.subcategory;
      if (post.files.length > 0) {
        Set ids = post.files.map((file) => file.idx).toSet();
        data['files'] = ids.join(',');
      }
      if (post.code != null && post.code != '') data['code'] = post.code;
    }

    final json = await request(data);
    return ApiPost.fromJson(json);
  }

  @Deprecated('user commentEdit()')
  Future<ApiComment> editComment({
    content = '',
    List<ApiFile> files,
    @required ApiPost post,
    ApiComment parent,
    ApiComment comment,
  }) async {
    final data = {
      'route': 'forum.editComment',
      'comment_post_ID': post.idx,
      // if (comment != null && comment.commentId != null && comment.commentId != '')
      //   'comment_ID': comment.commentId,
      // if (parent != null) 'comment_parent': parent.commentId,
      // 'comment_content': content ?? '',
    };
    if (files != null) {
      Set ids = files.map((file) => file.idx).toSet();
      data['files'] = ids.join(',');
    }
    final json = await request(data);
    return ApiComment.fromJson(json);
  }

  ///
  Future<ApiComment> commentEdit({
    String idx,
    String rootIdx,
    String parentIdx,
    String content,
    List<ApiFile> files,
    Map<String, dynamic> data,
    ApiComment comment,
  }) async {
    if (data == null) data = {};

    if (idx == null) {
      data['route'] = 'comment.create';
      data['rootIdx'] = rootIdx;
      data['parentIdx'] = parentIdx;
    } else {
      data['route'] = 'comment.update';
      data['idx'] = idx;
    }
    data['files'] = '';

    if (comment != null) {
      if (comment.files.length > 0) {
        Set ids = comment.files.map((file) => file.idx).toSet();
        data['files'] = ids.join(',');
      }
    } else {
      if (files != null && files.length > 0) {
        Set ids = files.map((file) => file.idx).toSet();
        data['files'] = ids.join(',');
      }
    }

    if (content != null) data['content'] = content;
    if (files != null) {
      Set ids = files.map((file) => file.idx).toSet();
      data['files'] = ids.join(',');
    }

    final json = await request(data);
    return ApiComment.fromJson(json);
  }

  @Deprecated('User postGet')
  Future<ApiPost> getPost(dynamic id) async {
    final json = await request({'route': 'forum.getPost', 'id': id});
    return ApiPost.fromJson(json);
  }

  ///
  Future<ApiPost> postGet(int idx) async {
    final json = await request({'route': 'post.get', 'idx': idx});
    return ApiPost.fromJson(json);
  }

  Future<List<ApiPost>> postGets(List<int> idxes) async {
    if (idxes.length == 0) return [];
    final jsonList = await request({'route': 'post.gets', 'idxes': idxes.join(',')});
    List<ApiPost> _posts = [];
    for (int i = 0; i < jsonList.length; i++) {
      _posts.add(ApiPost.fromJson(jsonList[i]));
    }
    return _posts;
  }

  /// Returns a post of today based on the categoryId and userIdx.
  /// 오늘 작성한 글을 가져온다.
  Future<List<ApiPost>> postToday(
      {@required String categoryId, String userIdx = '0', int limit = 10}) async {
    final map = await request(
        {'route': 'post.today', 'categoryId': categoryId, 'userIdx': userIdx, 'limit': limit});

    final List<ApiPost> rets = [];
    for (final p in map) {
      rets.add(ApiPost.fromJson(p));
    }
    return rets;
  }

  ///
  Future<ApiCategory> categoryCreate({String id, String title = ''}) async {
    final re = await request({'route': 'category.create', 'id': id, 'title': title});
    return ApiCategory.fromJson(re);
  }

  /// Category Update
  ///
  /// The [data] is a map of key/value pair to save.
  /// You may save a value composing with [field] and [value].
  Future<ApiCategory> categoryUpdate(
      {@required String id, String field, String value, Map<String, dynamic> data}) async {
    if (data == null) data = {};

    data['route'] = 'category.update';
    data['id'] = id;
    if (field != null) data[field] = value;

    final re = await request(data);
    return ApiCategory.fromJson(re);
  }

  ///
  Future<ApiCategory> categoryGet(String id) async {
    final re = await request({'route': 'category.get', 'id': id});
    return ApiCategory.fromJson(re);
  }

  ///
  Future<List<ApiCategory>> categoryGets(List<String> ids) async {
    final re = await request({'route': 'category.gets', 'ids': ids});
    final List<ApiCategory> rets = [];
    for (final j in re) {
      rets.add(ApiCategory.fromJson(j));
    }
    return rets;
  }

  Future<List<ApiCategory>> categorySearch({int limit = 10}) async {
    final re = await request({'route': 'category.search', 'limit': limit});
    final List<ApiCategory> rets = [];
    for (final j in re) {
      rets.add(ApiCategory.fromJson(j));
    }
    return rets;
  }

  /// Deletes a post.
  ///
  /// [post] is the post to be deleted.
  /// After the post has been deleted, it will be removed from [forum]
  ///
  /// It returns deleted file id.
  Future<String> postDelete(ApiPost post, [ApiForum forum]) async {
    final dynamic data = await request({
      'route': 'post.delete',
      'idx': post.idx,
    });
    if (forum != null) {
      int i = forum.posts.indexWhere((p) => p.idx == post.idx);
      forum.posts.removeAt(i);
    }
    return data['idx'];
  }

  /// Deletes a comment.
  ///
  /// [comment] is the comment to be deleted.
  /// [post] is the post of the comment.
  ///
  /// It returns deleted file id.
  Future<String> commentDelete(ApiComment comment, ApiPost post) async {
    final dynamic data = await request({
      'route': 'comment.delete',
      'idx': comment.idx,
    });
    int i = post.comments.indexWhere((c) => c.idx == comment.idx);
    post.comments.removeAt(i);
    return data['idx'];
  }

  @Deprecated('use postSearch()')

  /// Get posts from backend.
  ///
  /// You can use this to display some posts from the forum category. You may use this for displaying
  /// latest posts.
  Future<List<ApiPost>> searchPost({
    int postIdOnTop,
    String category,
    int limit = 20,
    int paged = 1,
    String author,
    String searchKey,
  }) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'forum.search';
    data['postIdOnTop'] = postIdOnTop;
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

  /// Get posts from backend.
  ///
  /// You may use [fetchPosts] wich handles with pagination and more.
  Future<List<ApiPost>> postSearch({
    String postOnTop,
    String categoryId,
    String subcategory,
    int limit = 20,
    int page = 1,
    String userIdx,
    String relationIdx,
    String searchKey = '',
  }) async {
    final Map<String, dynamic> data = {};
    data['route'] = 'post.search';
    data['postOnTop'] = postOnTop;
    data['where'] = "parentIdx=0 and deletedAt=0";
    data['page'] = page;
    data['limit'] = limit;

    if (userIdx != null) data['where'] = data['where'] + " and userIdx=$userIdx";
    if (relationIdx != null) data['where'] = data['where'] + " and relationIdx=$relationIdx";
    if (categoryId != null && categoryId != "")
      data['where'] = data['where'] + " and categoryId=<$categoryId>";
    if (subcategory != null) data['where'] = data['where'] + " and subcategory='$subcategory'";

    if (searchKey != null && searchKey != '') {
      data['where'] =
          data['where'] + " and (title like '%$searchKey%' or content like '%$searchKey%')";
      // Deliver search key to backend to save.
      data['searchKey'] = searchKey;
    }
    final jsonList = await request(data);

    List<ApiPost> _posts = [];
    for (int i = 0; i < jsonList.length; i++) {
      _posts.add(ApiPost.fromJson(jsonList[i]));
    }
    return _posts;
  }

  Future<List<ApiComment>> searchComments({
    String userIdx,
    int limit = 20,
    int page = 1,
    String order = 'DESC',
  }) async {
    final Map<String, dynamic> data = {
      'route': 'comment.search',
      'where': 'userIdx=$userIdx AND parentIdx > 0 and deletedAt=0',
      'limit': limit,
      'page': page
    };

    final jsonList = await request(data);

    List<ApiComment> _comments = [];
    for (int i = 0; i < jsonList.length; i++) {
      _comments.add(ApiComment.fromJson(jsonList[i]));
    }
    return _comments;
  }

  /// [getPosts] is an alias of [searchPosts]
  Future<List<ApiPost>> getPosts({String category, int limit = 20, int paged = 1, String userIdx}) {
    // return searchPost(category: category, limit: limit, paged: paged, author: author);
    return postSearch(categoryId: category, limit: limit, page: paged, userIdx: userIdx);
  }

  ///
  Future<dynamic> vote(dynamic postOrComment, String choice) async {
    String route;
    if ("${postOrComment.parentIdx}".toInt > 0) {
      route = 'comment.vote';
    } else {
      route = 'post.vote';
    }
    final re = await request({'route': route, 'idx': postOrComment.idx, 'choice': choice});
    if ("${postOrComment.parentIdx}".toInt > 0) {
      return ApiComment.fromJson(re);
    } else {
      return ApiPost.fromJson(re);
    }
  }

  Future<ApiFile> uploadFile({
    File file,
    Uint8List bytes,
    Function onProgress,
    bool deletePreviousUpload = false,
    String taxonomy = '',
    int entity = 0,
    String code = '',
  }) async {
    Prefix.FormData formData;
    if (file != null) {
      /// [Prefix] 를 쓰는 이유는 Dio 의 FromData 와 Flutter 의 기본 HTTP 와 충돌하기 때문이다.
      formData = Prefix.FormData.fromMap({
        /// `route` 와 `session_id` 등 추가 파라메타 값을 전달 할 수 있다.
        'route': 'file.upload',
        'sessionId': sessionId,
        'taxonomy': taxonomy,
        'entity': entity.toString(),
        'code': code,
        'deletePreviousUpload': deletePreviousUpload ? 'Y' : 'N',

        /// 아래에서 `userfile` 이, `$_FILES[userfile]` 와 같이 들어간다.
        'userfile': await Prefix.MultipartFile.fromFile(
          file.path,

          /// `filename` 은 `$_FILES[userfile][name]` 와 같이 들어간다.
          filename: getFilenameFromPath(file.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      });
    } else if (bytes != null) {
      /// [Prefix] 를 쓰는 이유는 Dio 의 FromData 와 Flutter 의 기본 HTTP 와 충돌하기 때문이다.
      formData = Prefix.FormData.fromMap({
        /// `route` 와 `session_id` 등 추가 파라메타 값을 전달 할 수 있다.
        'route': 'file.upload',
        'sessionId': sessionId,

        'taxonomy': taxonomy,
        'entity': entity.toString(),
        'code': code,
        'deletePreviousUpload': deletePreviousUpload ? 'Y' : 'N',

        /// 아래에서 `userfile` 이, `$_FILES[userfile]` 와 같이 들어간다.
        'userfile': Prefix.MultipartFile.fromBytes(
          bytes,

          /// `filename` 은 `$_FILES[userfile][name]` 와 같이 들어간다.
          filename: getFilenameFromPath(DateTime.now().toString().replaceAll(' ', '') + '.jpg'),
          contentType: MediaType('image', 'jpeg'),
        ),
      });
    }

    final res = await dio.post(
      apiUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (onProgress != null) onProgress(sent * 100 / total);
      },
    );

    print('res: $res');

    /// @todo  merge this error handling with [request]
    if (res.data is String || res.data['response'] == null) {
      throw (res.data);
    } else if (res.data['response'] is String) {
      throw res.data['response'];
    }
    return ApiFile.fromJson(res.data['response']);
  }

  /// 사진업로드
  ///
  /// 이미지를 카메라 또는 갤러리로 부터 가져와서, 이미지 누어서 찍힌 이미지를 바로 보정을 하고, 압축을 하고, 서버에 업로드
  /// [deletePreviousUpload] 가 true 이면, 기존에 업로드된 동일한 taxonomy 와 entity 파일을 삭제한다.
  ///
  Future<ApiFile> takeUploadFile({
    @required ImageSource source,
    int quality = 90,
    bool deletePreviousUpload = false,
    String taxonomy = '',
    int entity = 0,
    String code = '',
    @required Function onProgress,
  }) async {
    /// Pick image
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: source);
    if (pickedFile == null) throw ERROR_IMAGE_NOT_SELECTED;

    if (kIsWeb) {
      // final image = Image.network(pickedFile.path);
      final bytes = await pickedFile.readAsBytes();

      /// Upload with binary bytes
      return await uploadFile(
        bytes: bytes,
        deletePreviousUpload: deletePreviousUpload,
        onProgress: onProgress,
        taxonomy: taxonomy,
        entity: entity,
        code: code,
      );
    } else {
      // If it's mobile.
      File file;
      // If there is image compressor (mostly only mobile.)
      if (imageCompressor != null) {
        file = await imageCompressor(pickedFile.path, quality);
      } else {
        // if there is no compresstor.
        file = File(pickedFile.path);
      }

      print('code: $code in api.controller.dart::takeUploadfile');

      /// Upload with file
      return await uploadFile(
        file: file,
        deletePreviousUpload: deletePreviousUpload,
        onProgress: onProgress,
        taxonomy: taxonomy,
        entity: entity,
        code: code,
      );
    }
  }

  /// Deletes a file.
  ///
  /// [id] is the file id to delete.
  /// [postOrComment] is a post or a comment that the file is attached to. The
  /// file will be removed from the `files` array after deletion.
  ///
  /// It returns deleted file id.
  Future<int> deleteFile(String idx, {dynamic postOrComment}) async {
    final dynamic data = await request({
      'route': 'file.delete',
      'idx': idx,
    });
    int i = postOrComment.files.indexWhere((file) => file.idx == idx);
    postOrComment.files.removeAt(i);
    return int.parse("${data['idx']}");
  }

  /// Fetch posts based on the options of [forum]
  ///
  /// You can change the settings(options) of [forum] right before calling [fetchPosts].
  /// You may do `forum.category='abc'` for the first call and change `forum.category='def'`
  /// and `forum.author=5` on second call. You can change merely all the fetch options before
  /// calling it.
  ///
  /// If [postIdOnTop] is set, it will get the post on the top of the list following the posts of the same category of the post.
  ///   - And if it gets the next page of it, then [forum.postIdOnTop] should be removed and [forum.category] should be the `category` of [forum.postIdOnTop].
  ///
  /// The [forum.pageNo] is increased automatically.
  ///
  /// The [forum] setting should be declared in each forum list screen.
  Future<void> fetchPosts(ApiForum forum) async {
    if (forum.post != null && forum.posts.length == 0) {
      //
      forum.posts.add(forum.post);
      forum.render();
    }

    if (forum.canLoad == false) {
      // print(
      //   'Can not load anymore: loading: ${forum.loading},'
      //   ' noMorePosts: ${forum.noMorePosts}',
      // );
      return;
    }
    forum.loading = true;
    forum.render();

    List<ApiPost> _posts;
    _posts = await postSearch(
      postOnTop: forum.postOnTop,
      categoryId: forum.categoryId,
      subcategory: forum.subcategory,
      page: ++forum.pageNo,
      limit: forum.limit,
      // @todo search by user.idx
      userIdx: forum.userIdx,
      relationIdx: forum.relationIdx,
      searchKey: forum.searchKey,
    );

    // No more posts if it loads less than `forum.list` or even it loads 0 posts.
    if (_posts.length < forum.limit) {
      forum.noMorePosts = true;
      forum.loading = false;
    }

    _posts.forEach((ApiPost p) {
      // Don't show same post twice if forum.post is set.
      if (forum.post != null && forum.post.idx == p.idx) return;

      forum.posts.add(p);
    });

    forum.loading = false;
    forum.render();
  }

  /// Return true if there is no problem on user's profile or throws an error.
  Future<bool> checkUserProfile() async {
    print("checkUserProfile");
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

  Future<dynamic> sendPushNotificationToUsers(
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

  Future<ApiUser> subscribeOrUnsubscribeTopic(String topic) {
    return subscribeOrUnsubscribe(
      route: 'notification.topicSubscription',
      topic: topic,
    );
  }

  Future<ApiUser> subscribeOrUnsubscribe({String route, String topic}) async {
    Map<String, dynamic> req = {
      'route': route,
      'topic': topic,
    };
    final res = await request(req);
    user = ApiUser.fromJson(res);
    await _saveUserProfile(user);
    return user;
  }

  Future translationList() {
    return request({'route': 'translation.list', 'format': 'language-first'});
  }

  /// todo: [loadTranslations] may be called twice at start up. One from [onInit], the other from [onFirebaseReady].
  /// todo: make it one time call.
  _loadTranslationFromCenterX() async {
    final res = await request({'route': 'translation.list', 'format': 'language-first'});
    // print('loadTranslations() res: $res');

    /// When it is a List, there is no translation. It should be a Map when it has data.
    if (res is List) return;
    if (res is Map && res.keys.length == 0) return;

    // print('_loadTranslationFromCenterX();');
    // print(res);

    translationChanges.add(res);
  }

  /// loadSettings
  _loadSettingFromCenterX() async {
    final _settings = await request({'route': 'app.settings'});
    if (_settings == null) return;

    /// When it is a List, there is no translation. It should be a Map when it has data.
    if (_settings is List) return;
    if (_settings is Map && _settings.keys.length == 0) return;
    // print('_loadSettingFromCenterX();');
    // print(_settings);
    settings = {...settings, ..._settings};
    settingChanges.add(settings);
  }

  /// Initialize Messaging
  _initMessaging() async {
    /// Permission request for iOS only. For Android, the permission is granted by default.
    if (kIsWeb || Platform.isIOS) {
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
    // print('_initMessaging:: Getting token: $token');
    _saveTokenToDatabase(token);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);

    // When ever user logs in, update the token with user Id.
    authChanges.listen((user) {
      if (user == null) return;
      _saveTokenToDatabase(token);
    });
  }

  /// Save the token to backend.
  ///
  Future _saveTokenToDatabase(String token) {
    this.token = token;
    return updateToken(token);
  }

  /// 현재 카트 정보를 백업 시켜 놓는다.
  ///
  /// 예를 들어, 카트에 상품 A, B, C 3개가 들어가 있을 경우, 사용자가 상품 D 를 '바로 구매' 하는 경우,
  /// 상품 D 를 카트에 담아야지, 모든 로직이 쉽게 적용된다.
  /// 그래서, 기존 카트의 정보를 백업해 놓고, 다시 복구 할 수 있도록 한다.
  ///
  /// * 주의: cart 는 Get.put() 이 되었으므로, cart 리퍼런스를 유지한테 데이터만 백업을 해야 한다.
  List<ApiPost> _items = [];
  backupCart() {
    _items = cart.items;
    cart.items = [];
  }

  /// 장바구니 복구
  restoreCart() {
    cart.items = _items;
  }

  /// Return thumbnail image url of an upload file/image.
  ///
  /// The [src] is the URL of the image or file.idx.
  /// The [code] is the code of the file.code, It can display a photo by the first image of the code.
  /// 주의할 점은 [code] 를 사용하는 경우, 이미지 캐시를 하면, 새로 업로드를 해도, 캐시된 이미지가 변경되지 않을 수 있다. 이와 같은 경우, [src] 에 파일 번호를 사용하는 것이 좋다.
  String thumbnailUrl({
    String src,
    String code,
    int width = 320,
    int height = 320,
    int quality = 75,
    bool original = false,
  }) {
    String url = apiUrl.replaceAll('index.php', '');
    url += 'etc/phpThumb/phpThumb.php';

    url = url + '?src=$src&code=$code&w=$width&h=$height&f=jpeg&q=$quality';
    if (original) url += '&original=Y';
    return url;
  }

  /// 설정을 서버에 저장한다.
  /// 주의: 관리자만 사용 할 수 있다. 관리자가 아니면 백엔드에서 에러가 난다.
  setConfig(String code, dynamic data) {
    return request({
      'route': 'app.setConfig',
      'code': code,
      'data': data,
    });
  }

  Future<List<ApiPointHistory>> pointHistorySearch(
      {String select = 'idx, fromUserIdx, toUserIdx, createdAt',
      String where = '1',
      int page = 1,
      int limit = 10}) async {
    final histories = await request({
      'route': 'pointHistory.search',
      'select': select,
      'where': where,
      'page': page,
      'limit': limit
    });
    List<ApiPointHistory> rets = [];
    for (final history in histories) {
      rets.add(ApiPointHistory.fromJson(history));
    }
    return rets;
  }

  /// Load search keywords from Backend
  ///
  /// There is no pagination. And the data from backend is minimum. So, it would be okay without pagination.
  /// The [days] is the past days from today to get the searched keywords. It might be adjusted for the performance of getting resonable number of search results.
  Future<List<ApiSearchKeyStat>> searchKeyStats({int days = 1}) async {
    final searchKeys = await request({'route': 'searchKey.stats', 'days': days});

    List<ApiSearchKeyStat> rets = [];
    if (searchKeys is List) return rets;

    searchKeys.entries.forEach((item) {
      rets.add(ApiSearchKeyStat.fromJson(item));
    });

    return rets;
  }

  Future<ApiFriend> addFriend({@required String otherIdx}) {
    return request({'route': 'friend.add', 'otherIdx': otherIdx})
        .then((value) => ApiFriend.fromMap(value));
  }

  Future<List<ApiShortUser>> listFriend() async {
    final List list = await request({'route': 'friend.list'});
    return list.map((e) => ApiShortUser.fromJson(e)).toList();
  }
}
