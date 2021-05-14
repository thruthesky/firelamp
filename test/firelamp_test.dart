import 'package:flutter_test/flutter_test.dart';

import 'package:firelamp/firelamp.dart' show Api, ApiPost;

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

  /// Shared variables
  ///
  final now = DateTime.now().microsecondsSinceEpoch;
  final userAEmail = 'userA$now@test.com';
  final userBEmail = 'userB$now@test.com';
  final testPassword = '12345a';
  final categoryId = 'qna';

  /// !NOTE: this is used for comment group tests to prevent creating posts each and every comment test.
  ApiPost? testPost;

  setUp(() async {
    await api.loginOrRegister(email: userAEmail, password: testPassword);
    testPost = await api.postEdit(
      title: 'testPost',
      content: 'testPost Content',
      categoryId: categoryId,
    );
  });

  test('check version', () async {
    final res = await call(api.version());
    expect(res, isNot(null));
  });

  ///
  /// USER CRUD
  ///
  /// Tests
  ///  - Fail Register with empty email
  ///  - Fail Register with malformed email
  ///  - Fail Register with empty password
  ///  - Fail Login with empty email
  ///  - Fail login with empty password
  ///  - Fail Profile update when not logged in
  ///  - Success login
  ///  - Success register
  ///  - success profile update with nickname
  ///
  group('USER CRUD', () {
    /// Test data
    final testEmail = 'user$now@test.com';

    final testName = 'name$now';
    final testNickname = 'nick$now';
    final unknownEmail = 'unknown$now@test.com';

    test('[REGISTER] -- Expect failure with empty email', () async {
      final res = await call(api.register(email: '', password: testPassword));
      expect(res, 'error_email_is_empty');
    });

    test('[REGISTER] -- Expect failure with malformed email', () async {
      final res = await call(api.register(email: 'not email', password: testPassword));
      expect(res, 'error_malformed_email');
    });

    test('[REGISTER] -- Expect failure without password', () async {
      final res = await call(api.register(email: testEmail, password: ''));
      expect(res, 'error_empty_password');
    });

    test('[LOGIN] -- Expect failure with empty email.', () async {
      final res = await call(api.login(email: '', password: testPassword));
      expect(res, 'error_email_is_empty');
    });

    test('[LOGIN] -- Expect failure wrong/unregistered email.', () async {
      final res = await call(api.login(email: unknownEmail, password: testPassword));
      expect(res, 'error_user_not_found_by_that_email');
    });

    test('[LOGIN] -- Expect failure without password.', () async {
      final res = await call(api.login(email: testEmail, password: ''));
      expect(res, 'error_empty_password');
    });

    test('[UPDATE] -- Expect error updating profile while not logged in.', () async {
      await api.logout(); // logout first
      final res = await call(api.userUpdate({'nickname': testNickname + ' eddit'}));
      expect(res, 'error_not_logged_in');
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

    test('[LOGIN] -- Expect success on logging in.', () async {
      final res = await call(api.login(email: testEmail, password: testPassword));
      expect(res?.email, testEmail);
      expect(api.user?.email, testEmail);
    });

    test('[UPDATE] -- Expect success updating user`s nickname.', () async {
      await api.loginOrRegister(email: testEmail, password: testPassword); // login first
      final res = await call(api.userUpdate({'nickname': testNickname})); // update nickname
      expect(res?.nickname, testNickname); // result nickname must match input nickname
      expect(api.user?.nickname, testNickname); // api user's nickname must match input nickname
    });
  });

  ///
  /// Post Crud
  ///
  /// Tests
  ///  - Fail create without login
  ///  - Fail create without category ID
  ///  - Fail update post of other user
  ///  - Fail delete post of other user
  ///  - Success with login and category ID
  ///  - Success update own post
  ///  - Success delete own post
  ///
  group('Post CRUD', () {
    test('[CREATE] -- Expect failure creating post without logging in.', () async {
      await api.logout(); // ensure no user is logged in.
      final res = await call(api.postEdit(title: 'some title', content: 'some content'));
      expect(res, 'error_not_logged_in');
    });

    test('[CREATE] -- Expect failure creating post without category ID.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await call(api.postEdit(title: 'some title', content: 'some content'));
      expect(res, 'error_category_id_is_empty');
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

    test('[DELETE] -- Expect failure deleting other user post.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A

      /// create post
      final createdPost = await api.postEdit(
        title: 'test update',
        content: 'test update content',
        categoryId: categoryId,
      );

      await api.loginOrRegister(email: userBEmail, password: testPassword); // login as B

      /// update post title and content
      final res = await call(api.postDelete(createdPost!));
      expect(res, 'error_not_your_post');
    });

    test('[CREATE] -- Expect success on creating post.', () async {
      final postTitle = 'title $now';
      final postContent = 'content $now';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final res = await call(api.postEdit(
        title: postTitle,
        content: postContent,
        categoryId: categoryId,
      ));

      expect(res?.title, postTitle);
      expect(res?.content, postContent);
    });

    test('[UPDATE] -- Expect success on update post.', () async {
      final updatedPostTitle = 'title $now';
      final updatedPostContent = 'content $now';

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

    test('[DELETE] -- Expect success deleting own post.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A

      /// create post
      final createdPost = await api.postEdit(
        title: 'test update',
        content: 'test update content',
        categoryId: categoryId,
      );

      /// update post title and content
      final res = await call(api.postDelete(createdPost!));
      expect(res, createdPost.idx);
    });
  });

  ///
  /// Comment CRUD
  ///
  ///
  /// Tests
  ///  - Fail create without login
  ///  - Fail create without rootIdx
  ///  - Fail update other user comment
  ///  - Fail delete other user comment
  ///  - Success creating comment
  ///  - Success replying to other comment
  ///  - Success updating own comment
  ///  - Success deleting own comment
  ///
  group('Comment CRUD', () {
    test('[CREATE] -- Expect failure creating comment without logging in.', () async {
      await api.logout(); // ensure no user is logged in.
      final res = await call(api.commentEdit(
        content: 'some content',
        parentIdx: testPost!.idx,
        rootIdx: testPost!.idx,
      ));
      expect(res, 'error_not_logged_in');
    });

    test('[CREATE] -- Expect failure creating comment without rootIdx.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await call(api.commentEdit(content: 'some content'));
      expect(res, 'error_root_idx_is_empty');
    });

    test('[UPDATE] -- Expect failure updating other user comment.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: 'some content',
        rootIdx: testPost!.idx,
      );

      await api.loginOrRegister(email: userBEmail, password: testPassword);
      final res = await call(api.commentEdit(content: 'some content', idx: createdComment.idx));
      expect(res, 'error_not_your_comment');
    });

    test('[DELETE] -- Expect failure deleting other user comment.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: 'some content',
        rootIdx: testPost!.idx,
      );

      await api.loginOrRegister(email: userBEmail, password: testPassword);
      final res = await call(api.commentDelete(createdComment, testPost!));
      expect(res, 'error_not_your_comment');
    });

    test('[CREATE] -- Expect success creating comment.', () async {
      final commentContent = 'comment $now';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: commentContent,
        rootIdx: testPost!.idx,
      );

      expect(createdComment.content, commentContent);
      expect(createdComment.rootIdx, testPost!.idx);
      expect(createdComment.parentIdx, testPost!.idx);
    });

    test('[REPLY] -- Expect success replying to a comment.', () async {
      final replyContent = 'reply $now';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: 'some content',
        rootIdx: testPost!.idx,
      );

      await api.loginOrRegister(email: userBEmail, password: testPassword);

      final commentReply = await api.commentEdit(
        content: replyContent,
        rootIdx: testPost!.idx,
        parentIdx: createdComment.idx,
      );

      expect(commentReply.content, replyContent);
      expect(commentReply.rootIdx, testPost!.idx);
      expect(commentReply.parentIdx, createdComment.idx);
    });

    test('[UPDATE] -- Expect success updating own comment.', () async {
      final updateContent = 'reply $now';

      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: 'some content',
        rootIdx: testPost!.idx,
      );

      final updatedComment = await api.commentEdit(
        content: updateContent,
        idx: createdComment.idx,
      );

      expect(updatedComment.content, updateContent);
      expect(updatedComment.rootIdx, testPost!.idx);
      expect(updatedComment.idx, createdComment.idx);
    });

    test('[DELETE] -- Expect success deleting own comment.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);

      final createdComment = await api.commentEdit(
        content: 'some content',
        rootIdx: testPost!.idx,
      );

      testPost?.comments?.add(createdComment);
      final res = await api.commentDelete(createdComment, testPost!);
      expect(res, createdComment.idx);
    });
  });

  ///
  /// Vote
  ///
  ///
  /// Tests
  ///  - Fail when voting while not logged in
  ///  - Fail when voting without provided choice
  ///  -
  ///
  group('VOTE test', () {
    test('[VOTE] -- Expect fail voting without choice.', () async {
      await api.logout();
      final res = await call(api.vote(testPost, 'Y'));
      expect(res, 'error_not_logged_in');
    });

    test('[VOTE] -- Expect fail voting without choice.', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword);
      final res = await call(api.vote(testPost, ''));
      expect(res, 'error_empty_vote_choice');
    });

    test('[VOTE] -- Expect success voting', () async {
      await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A
      final voteA = await call(api.vote(testPost, 'Y')); // vote like
      expect(voteA.y, '1'); // like must be 1

      await api.loginOrRegister(email: userBEmail, password: testPassword); // login as B
      final voteB = await call(api.vote(testPost, 'Y')); // vote like (same post)
      expect(voteB.y, '2'); // like must be 2

      final voteC = await call(api.vote(testPost, 'Y')); // vote like (same post)
      expect(voteC.y, '1'); // like must be 1 because B already voted like which will remove his vote.

      await api.loginOrRegister(email: userAEmail, password: testPassword); // login as A
      final voteD = await call(api.vote(testPost, 'N')); // vote like
      expect(voteD.n, '1'); // dislike must be 1
      expect(voteD.y, '0'); // like must be 0
    });
  });
}
