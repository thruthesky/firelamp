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
  /// The [category] is used on fetching posts.
  String category;

  /// The [author] is used on fetching to get the user's posts only.
  String author;

  /// The [searchKey] is used on fetching to search posts
  String searchKey;

  /// The post of [postIdOnTop] will be shown on top of the post list with other posts.
  /// Use this when user want to see(view) a post. It may serve as a view page.
  /// The following posts is coming same category if [category] is not set.
  /// It is ignored when [searchKey] is set.
  int postIdOnTop;

  /// The post to be shown on top of the list.
  /// This may also serve as a post view page. Since it has a complete post information,
  /// it will be immediately available before getting data from backend.
  /// When [fetchPost] is being called, [render] will be immidately called with this post.
  ApiPost post;

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

  bool get showLike => showVoteButton('forum_like');
  bool get showDislike => showVoteButton('forum_dislike');

  bool get canSearch {
    if (postInEdit != null) return false;
    if (author != null) return false;
    return true;
  }

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
    post,
  }) : this.posts = post != null ? [post] : [];

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
