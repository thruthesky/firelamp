import 'package:flutter_test/flutter_test.dart';

import 'package:firelamp/firelamp.dart' show Api;

final api = Api();

void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();
  await api.init(apiUrl: 'https://local.itsuda50.com/index.php', enableFirebase: false);
  final now = DateTime.now();

  test('check version', () async {
    final res = await api.version();
    print(res);
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
      await api.register(email: '', password: testPassword).catchError((e) {
        expect(e, 'error_malformed_email');
      });
    });

    test('[REGISTER] -- Expect fail without password', () async {
      await api.register(email: testEmail, password: '').catchError((e) {
        expect(e, 'error_empty_password');
      });
    });

    test('[REGISTER] -- Expect success', () async {
      final res = await api.register(
        email: testEmail,
        password: testPassword,
        data: {'name': testName},
      ).catchError((e) {
        print(e);
        expect(e, null, reason: 'This test should success registering in with email and password.');
      });
      expect(res?.email, testEmail);
      expect(api.user?.email, testEmail);
      expect(res?.name, testName);
      expect(api.user?.name, testName);
    });

    test('[LOGIN] -- Expect fail with empty email', () async {
      final res = await api.login(email: '', password: testPassword).catchError((e) {
        expect(e, 'error_email_is_empty');
      });
      expect(res, null, reason: 'This should fail attempting to login without email.');
    });

    test('[LOGIN] -- Expect fail wrong/unregistered email', () async {
      final res = await api.login(email: unknownEmail, password: testPassword).catchError((e) {
        expect(e, 'error_user_not_found_by_that_email');
      });
      expect(res, null, reason: 'This should fail attempting to login with unregistered email.');
    });

    test('[LOGIN] -- Expect fail without password', () async {
      final res = await api.login(email: testEmail, password: '').catchError((e) {
        expect(e, 'error_empty_password');
      });
      expect(res, null, reason: 'User must not be able to register without password.');
    });

    test('[LOGIN] -- Expect success', () async {
      final res = await api.login(email: testEmail, password: testPassword).catchError((e) {
        expect(e, null, reason: 'This test should success logging in with right email and password.');
      });
      expect(res?.email, testEmail);
      expect(api.user?.email, testEmail);
    });

    test('[UPDATE] -- Expect success', () async {
      await api.login(email: testEmail, password: testPassword); // login first
      final res = await api.userUpdate({'nickname': testNickname}); // update nickname
      expect(res?.nickname, testNickname); // result nickname must match input nickname
      expect(api.user?.nickname, testNickname); // api user's nickname must match input nickname
    });

    test('[UPDATE] -- Expect error updating profile while not logged in', () async {
      await api.logout(); // logout first
      final res = await api.userUpdate({'nickname': testNickname + ' eddit'}).catchError((e) {
        expect(e, 'error_not_logged_in');
      });
      expect(res, null, reason: 'This test should fail attempting to update user without logging in');
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
      final res = await api.postEdit(title: 'some title', content: 'some content').catchError((e) {
        expect(e, 'error_not_logged_in');
      });
      expect(res, null, reason: 'This test should fail attempting to create post without logging in');
    });

    test('[CREATE] -- Expect fail creating post without category ID', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await api.postEdit(title: 'some title', content: 'some content').catchError((e) {
        expect(e, 'error_category_id_is_empty');
      });
      expect(res, null,
          reason: 'This test should fail attempting to create post without category ID');
    });

    test('[CREATE] -- Expect success', () async {
      final postTitle = 'title ${now.microsecondsSinceEpoch}';
      final postContent = 'content ${now.microsecondsSinceEpoch}';

      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await api
          .postEdit(title: postTitle, content: postContent, categoryId: categoryId)
          .catchError((e) {
        expect(e, null, reason: 'This test should fail attempting to create post without logging in');
      });

      expect(res?.title, postTitle);
      expect(res?.content, postContent);
      await api.postDelete(res!); // delete to prevent spamming server
    });

    // test('[UPDATE] -- Expect success', () async {
    //   final updatedPostTitle = 'title ${now.microsecondsSinceEpoch}';
    //   final updatedPostContent = 'content ${now.microsecondsSinceEpoch}';

    //   await api.loginOrRegister(email: userAEmail, password: testPassword);

    //   /// create post
    //   final res = await api.postEdit(
    //     title: 'test update',
    //     content: 'test update content',
    //     categoryId: categoryId,
    //   );

    //   /// update post title and content
    //   final resUp = await api
    //       .postEdit(title: updatedPostTitle, content: updatedPostContent, idx: res?.idx)
    //       .catchError((e) {
    //     expect(
    //       e,
    //       null,
    //       reason: 'This test should pass updating created post.',
    //     );
    //   });

    //   expect(resUp?.title, updatedPostTitle);
    //   expect(resUp?.content, updatedPostContent);
    // });

    // test('[UPDATE] -- Expect failure updating other user post.', () async {
    //   await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A

    //   /// create post
    //   final res = await api.postEdit(
    //     title: 'test update',
    //     content: 'test update content',
    //     categoryId: categoryId,
    //   );

    //   await api.loginOrRegister(email: userBEmail, password: testPassword); // login as B

    //   /// update post title and content
    //   final resUp = await api
    //       .postEdit(title: 'some title', content: 'some content', idx: res?.idx)
    //       .catchError((e) {
    //     expect(e, 'error_not_your_post');
    //   });
    //   expect(resUp, null, reason: 'This test should fail updating other user post.');
    // });
  });
}
