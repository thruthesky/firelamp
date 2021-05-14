import 'package:flutter_test/flutter_test.dart';

import 'package:firelamp/firelamp.dart' show Api;

final api = Api();

call(Future<dynamic> apiCall) async {
  dynamic ret;
  try {
    ret = await apiCall;
  } catch (e) {
    ret = e;
  }
  return ret;
}

void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();
  await api.init(apiUrl: 'https://local.itsuda50.com/index.php', enableFirebase: false);
  final now = DateTime.now();

  test('check version', () async {
    final res = await call(api.version());
    expect(res, isNot(null));
  });

  ///
  /// USER CRUD
  ///
  group('USER CRUD', () {
    /// Test data
    final testEmail = 'user${now.microsecondsSinceEpoch}@test.com';
    final testPassword = '12345a';

    final testName = 'name${now.microsecondsSinceEpoch}';
    final testNickname = 'nick${now.microsecondsSinceEpoch}';
    final unknownEmail = 'unknown${now.microsecondsSinceEpoch}@test.com';

    test('[REGISTER] -- Expect fail with empty email', () async {
      final res = await call(api.register(email: '', password: testPassword));
      expect(res, 'error_malformed_email');
    });

    test('[REGISTER] -- Expect fail without password', () async {
      final res = await call(api.register(email: testEmail, password: ''));
      expect(res, 'error_empty_password');
    });

    test('[REGISTER] -- Expect success', () async {
      final res = await call(api.register(
        email: testEmail,
        password: testPassword,
        data: {'name': testName},
      ));

      expect(res?.email, testEmail);
      expect(api.user?.email, testEmail);
      expect(res?.name, testName);
      expect(api.user?.name, testName);
    });

    test('[LOGIN] -- Expect fail with empty email', () async {
      final res = await call(api.login(email: '', password: testPassword));
      expect(res, 'error_email_is_empty');
    });

    test('[LOGIN] -- Expect fail wrong/unregistered email', () async {
      final res = await call(api.login(email: unknownEmail, password: testPassword));
      expect(res, 'error_user_not_found_by_that_email');
    });

    test('[LOGIN] -- Expect fail without password', () async {
      final res = await call(api.login(email: testEmail, password: ''));
      expect(res, 'error_empty_password');
    });

    test('[LOGIN] -- Expect success', () async {
      final res = await call(api.login(email: testEmail, password: testPassword));
      expect(res?.email, testEmail);
      expect(api.user?.email, testEmail);
    });

    test('[UPDATE] -- Expect success', () async {
      await api.loginOrRegister(email: testEmail, password: testPassword); // login first
      final res = await call(api.userUpdate({'nickname': testNickname})); // update nickname
      expect(res?.nickname, testNickname); // result nickname must match input nickname
      expect(api.user?.nickname, testNickname); // api user's nickname must match input nickname
    });

    test('[UPDATE] -- Expect error updating profile while not logged in', () async {
      await api.logout(); // logout first
      final res = await call(api.userUpdate({'nickname': testNickname + ' eddit'}));
      expect(res, 'error_not_logged_in');
    });
  });

  ///
  /// Post Crud
  ///
  group('Post CRUD', () {
    /// Test data
    final userAEmail = 'userA${now.microsecondsSinceEpoch}@test.com';
    final userBEmail = 'userB${now.microsecondsSinceEpoch}@test.com';
    final testPassword = '12345a';
    final categoryId = 'qna';

    test('[CREATE] -- Expect fail creating post without logging in', () async {
      await api.logout();
      final res = await call(api.postEdit(title: 'some title', content: 'some content'));
      expect(res, 'error_not_logged_in');
    });

    test('[CREATE] -- Expect fail creating post without category ID', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await call(api.postEdit(title: 'some title', content: 'some content'));
      expect(res, 'error_category_id_is_empty');
    });

    test('[CREATE] -- Expect success', () async {
      final postTitle = 'title ${now.microsecondsSinceEpoch}';
      final postContent = 'content ${now.microsecondsSinceEpoch}';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final res = await call(api.postEdit(
        title: postTitle,
        content: postContent,
        categoryId: categoryId,
      ));

      expect(res?.title, postTitle);
      expect(res?.content, postContent);
    });

    test('[UPDATE] -- Expect success', () async {
      final updatedPostTitle = 'title ${now.microsecondsSinceEpoch}';
      final updatedPostContent = 'content ${now.microsecondsSinceEpoch}';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      /// create post
      final createdPost = await api.postEdit(
        title: 'test update',
        content: 'test update content',
        categoryId: categoryId,
      );

      /// update post title and content
      final res = await call(api.postEdit(
        title: updatedPostTitle,
        content: updatedPostContent,
        idx: createdPost?.idx,
      ));

      expect(res?.title, updatedPostTitle);
      expect(res?.content, updatedPostContent);
    });

    test('[UPDATE] -- Expect failure updating other user post.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A

      /// create post
      final createdPost = await api.postEdit(
        title: 'test update',
        content: 'test update content',
        categoryId: categoryId,
      );

      await api.loginOrRegister(email: userBEmail, password: testPassword); // login as B

      /// update post title and content
      final res = await call(api.postEdit(
        title: 'some title',
        content: 'some content',
        idx: createdPost?.idx,
      ));

      expect(res, 'error_not_your_post');
    });
  });
}
