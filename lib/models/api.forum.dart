part of '../firelamp.dart';

/// Forum model
///
/// [Forum] is a data model for a forum category.
///
/// Note that forum data model must not connect to backend directly by using API controller. Instead, the API controller
/// will use the instance of this forum model.
///
/// [Forum] only manages the data of a category.
class ApiForum {
  String category;
  String author;
  String searchKey;
  List<ApiPost> posts;
  bool loading = false;
  bool noMorePosts = false;
  int pageNo = 1;
  int limit = 10;
  bool get canLoad => loading == false && noMorePosts == false;
  bool get canList => postInEdit == null && posts.length > 0;
  final ItemScrollController listController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  Function render;

  
  bool get showLike => showVoteButton('forum_like');
  bool get showDislike => showVoteButton('forum_dislike');

  bool showVoteButton(String str) {
    if (Api.instance.settings[str] != null && Api.instance.settings[str] == 'Y') {
      return true;
    }
    return false;
  }

  ApiPost postInEdit;
  ApiForum({
    this.category,
    this.author,
    this.searchKey,
    this.limit = 10,
    @required this.render,
    posts,
  }) : this.posts = posts ?? [];

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
