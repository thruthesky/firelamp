part of '../firelamp.dart';

/// [ApiPost] is a model for a post.
///
/// Post can be used for many purpose like blog, messaging, shopping mall, etc.
class ApiPost {
  ApiPost({
    this.data,
    this.id,
    this.postAuthor,
    this.postDate,
    this.postContent,
    this.postTitle,
    this.postModified,
    this.postParent,
    this.guid,
    this.commentCount,
    this.postCategory,
    this.files,
    this.authorName,
    this.shortDateTime,
    this.comments,
    this.category,
    this.featuredImageUrl,
    this.featuredImageThumbnailUrl,
    this.featuredImageId,
    this.shortTitle,
    this.price,
    this.discountRate,
    this.stop,
    this.point,
    this.volume,
    this.deliveryFee,
    this.storageMethod,
    this.expiry,
    this.itemPrimaryPhoto,
    this.itemWidgetPhoto,
    this.itemDetailPhoto,
    this.keywords,
    this.options,
  }) {
    if (files == null) files = [];
    if (postTitle == null) postTitle = '';
    if (postContent == null) postContent = '';
  }

  /// [data] is the original data for the post. When you need to access an extra meta property,
  /// you can access [data] directly.
  dynamic data;
  int id;
  String postAuthor;
  DateTime postDate;
  String postContent;
  String postTitle;
  DateTime postModified;
  int postParent;
  String guid;
  String commentCount;
  List<int> postCategory;
  List<ApiFile> files;
  String authorName;
  String shortDateTime;
  List<ApiComment> comments;
  String category;

  String featuredImageUrl;
  String featuredImageThumbnailUrl;
  int featuredImageId;

  /// Shopping mall properties
  ///
  String shortTitle;
  int price;
  int discountRate;
  bool stop;
  int point;
  int volume;
  int deliveryFee;
  String storageMethod;
  String expiry;
  String itemPrimaryPhoto;
  String itemWidgetPhoto;
  String itemDetailPhoto;

  /// The [keywords] has multiple keywords separated by comma
  String keywords;

  /// The [options] has multiple options separated by comma
  List<String> options;

  ///
  bool get isMine => postAuthor == Api.instance.id;
  bool get isNotMine => !isMine;

  /// Display options
  ///
  /// The [display] flag tells whether to show or hide the post in list.
  /// [display] 는 클라이언트에서만 사용되는 것으로, true 이면 글(내용)을 보여주는 것이다.
  bool display = false;

  /// Update mode
  ///
  /// The [mode] has one of the following status: null, 'edit'
  /// - when it is 'edit', the post is in edit mode.
  String mode;

  ///
  insertOrUpdateComment(ApiComment comment) {
    // print(comment.commentParent);

    // find existing comment and update.
    int i = comments.indexWhere((c) => c.commentId == comment.commentId);
    if (i != -1) {
      comment.depth = comments[i].depth;
      comments[i] = comment;
      return;
    }

    // if it's new comment right under post, then add at bottom.
    if (comment.commentParent == '0') {
      comments.add(comment);
      // print('parent id: 0, add at bottom');
      return;
    }

    // find parent and add below the parent.
    int p = comments.indexWhere((c) => c.commentId == comment.commentParent);
    if (p != -1) {
      comment.depth = comments[p].depth + 1;
      comments.insert(p + 1, comment);
      return;
    }

    // error. code should not come here.
    // print('error on comment add:');
  }

  factory ApiPost.fromJson(Map<String, dynamic> json) {
    return ApiPost(
      data: json,
      id: json["ID"] is String ? int.parse(json["ID"]) : json["ID"],
      postAuthor: json["post_author"],
      postDate: DateTime.parse(json["post_date"]),
      postContent: json["post_content"],
      postTitle: json["post_title"],
      postModified: DateTime.parse(json["post_modified"]),
      postParent: json["post_parent"],
      guid: json["guid"],
      commentCount: json["comment_count"],
      postCategory: List<int>.from(json["post_category"].map((x) => x)),
      files: List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
      authorName: json["author_name"],
      shortDateTime: json["short_date_time"],
      comments: List<ApiComment>.from(json["comments"].map((x) => ApiComment.fromJson(x))),
      category: json["category"],
      featuredImageUrl: json["featured_image_url"],
      featuredImageThumbnailUrl: json["featured_image_thumbnail_url"],
      featuredImageId: json["featured_image_ID"] == null
          ? 0
          : json["featured_image_ID"] is int
              ? json["featured_image_ID"]

              /// Fix bug here, parse and return int if not as int already.
              : int.parse(json["featured_image_ID"]),
      shortTitle: json["short_title"],
      price: _parseInt(json["price"]),
      discountRate: _parseInt(json["discount_rate"]),
      stop: json["stop"] == null || json["stop"] == ""
          ? false
          : int.parse(json["stop"]) == 1
              ? true
              : false,
      point: _parseInt(json["point"]),
      volume: _parseInt(json["volume"]),
      deliveryFee: _parseInt(json["delivery_fee"]),
      storageMethod: json["storage_method"],
      expiry: json["expiry"],
      itemPrimaryPhoto: json["item_primary_photo"],
      itemWidgetPhoto: json["item_widget_photo"],
      itemDetailPhoto: json["item_detail_photo"],
      keywords: json['keywords'] ?? '',
      options: json['options'] == null ? [] : splitByComma(json['options']),
    );
  }

  Map<String, dynamic> toJson() => {
        "ID": id,
        "post_author": postAuthor,
        if (postDate != null) "post_date": postDate.toIso8601String(),
        "post_content": postContent,
        "post_title": postTitle,
        if (postModified != null) "post_modified": postModified.toIso8601String(),
        "post_parent": postParent,
        "guid": guid,
        "comment_count": commentCount,
        if (postCategory != null) "post_category": List<dynamic>.from(postCategory.map((x) => x)),
        "files": List<dynamic>.from(files.map((x) => x.toJson().toString())),
        "author_name": authorName,
        "short_date_time": shortDateTime,
        if (comments != null)
          "comments": List<dynamic>.from(comments.map((x) => x.toJson().toString())),
        "category": category,
        "featured_image_url": featuredImageUrl,
        "featured_image_thumbnail_url": featuredImageThumbnailUrl,
        "featured_image_ID": featuredImageId,
        "shortTitle": shortTitle,
        "price": price,
        "discountRate": discountRate,
        "stop": stop,
        "point": point,
        "volume": volume,
        "deliveryFee": deliveryFee,
        "storageMethod": storageMethod,
        "expiry": expiry,
        "itemPrimaryPhoto": itemPrimaryPhoto,
        "itemWidgetPhoto": itemWidgetPhoto,
        "itemDetailPhoto": itemDetailPhoto,
        "keywords": keywords,
        "options": options.toString,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  static int _parseInt(String n) {
    if (n is String) {
      if (n == null || n == '') return 0;
      return int.parse(n);
    }
    return 0;
  }

  static List<String> splitByComma(String str) {
    if (str == null) return [];
    str = str.trim();
    if (str == '') return [];

    return str.split(',').map((s) => s.trim()).takeWhile((s) => s != '').toList();
  }
}
