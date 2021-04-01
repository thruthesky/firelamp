part of '../firelamp.dart';

/// Forum model
///
/// [Forum] is a data model for a forum category.
///
/// Note that forum data model must not connect to backend directly by using API controller. Instead, the API controller
/// will use the instance of this forum model.
///
/// [Forum] only manages the data of a category.
///
/// 사용자가 글 목록 스크린을 스크롤 할 때, 맨 아래 부분에 스크롤이 도달했을 때, 남은 아이템의 수가 [loadMoreOn] 보다 작다면,
/// 다음 글 목록을 하는 콜백 함수 [loadMore] 를 호출 한다.
class ApiForum {
  /// Forum category settings
  ApiCategory setting;

  String get listView {
    if (setting == null) return 'text';
    if (setting.mobilePostListWidget.isBlank) return 'text';
    return setting.mobilePostListWidget;
  }

  String get postView {
    if (setting == null) return 'default';
    if (setting.mobilePostViewWidget.isBlank) return 'default';
    return setting.mobilePostViewWidget;
  }

  /// App can set the limit to get posts per page.
  int _limit;
  int get limit {
    // If limit is set by app.
    if (_limit != null) return _limit;
    // If setting is not set, then 10.
    if (setting == null) return 10;
    if (setting.noOfPostsPerPage.toInt < 1) return 10;
    return setting.noOfPostsPerPage.toInt;
  }

  /// The [_categoryId] is used on fetching posts.
  String _categoryId;

  /// If [_categoryId] is not set, then use it from [setting.id]
  String get categoryId => _categoryId ?? setting?.id;
  set categoryId(String categoryId) => this._categoryId = categoryId;
  String subcategory;

  /// The [userIdx] is used on fetching to get the user's posts only.
  String userIdx;

  /// The [relationIdx] is used to fetch posts related with an entity of [relationIdx].
  String relationIdx;

  /// The [searchKey] is used on fetching to search posts
  String searchKey;

  /// The post of [postOnTop] will be shown on top of the post list with other posts.
  /// Use this when user want to see(view) a post. It may serve as a view page.
  /// The following posts is coming same category if [category] is not set.
  /// It is ignored when [searchKey] is set.
  String postOnTop;

  /// The post to be shown on top of the list.
  /// This may also serve as a post view page. Since it has a complete post information,
  /// it will be immediately available before getting data from backend.
  /// When [fetchPost] is being called, [render] will be immidately called with this post.
  ApiPost post;

  List<ApiPost> posts = [];
  bool loading = false;
  bool noMorePosts = false;
  int pageNo = 0;
  bool get canLoad => loading == false && noMorePosts == false;
  bool get canList => postInEdit == null && posts.length > 0;

  /// 구글에서 제작한 Scrollable Positioned List https://pub.dev/packages/scrollable_positioned_list
  /// 장점은 글 생성/수정 후, 해당(또는 특정) 글 위치로 이동을 할 수 있다.
  /// 하지만, 다음 페이지 로딩을 할 때, 마지막에 몇개 아이템 남았을 때 이동할지 결정은 직접 코드를 작성해야 한다.
  final ItemScrollController listController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  /// [render] 는 게시판 목록을 다시 그려야 할 때, 사용되는데, 문제가 많다. GetX Controller 나 RxDart 로 변경을 해야 한다.
  Function render;

  bool get showLike => showVoteButton('forum_like');
  bool get showDislike => showVoteButton('forum_dislike');

  // categories separated by comma.
  String get searchCategories => Api.instance.settings['search_categories'] ?? '';

  bool get canCreate => userIdx == null && categoryId != null && postInEdit == null;

  bool get hasPosts => posts.isNotEmpty;
  bool get noPosts => posts.isEmpty;

  bool showVoteButton(String str) {
    if (Api.instance.settings[str] != null && Api.instance.settings[str] == 'Y') {
      return true;
    }
    return false;
  }

  int loadMoreOn;
  Function loadMore;

  ///
  ApiPost postInEdit;
  ApiForum({
    this.setting,
    this.subcategory,
    this.userIdx,
    this.relationIdx,
    this.searchKey,
    int limit,
    this.render,
    this.loadMoreOn,
    this.loadMore,
    String categoryId,
    ApiPost post,
  })  : _limit = limit,
        this._categoryId = categoryId ?? setting?.id,
        this.posts = post != null ? [post] : [] {
    /// 게시글 목록에서, 스크롤이 밑으로 내려가면, loadMoreOn 개수 만큼 남았을 때, 다음 페이지를 로드하는 콜백 함수를 호출한다.
    if (loadMoreOn != null) {
      itemPositionsListener.itemPositions.addListener(() {
        int lastVisibleIndex = itemPositionsListener.itemPositions.value.last.index;
        if (canLoad == false) return;
        print('canLoad: $canLoad, lastVisibleIndex: $lastVisibleIndex');
        if (lastVisibleIndex > posts.length - loadMoreOn) {
          loadMore();
        }
      });
    }
  }

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
  insertOrUpdatePost(ApiPost post) {
    postInEdit = null;
    int i = posts.indexWhere((p) => p.idx == post.idx);
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
