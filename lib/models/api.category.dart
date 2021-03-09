// To parse this JSON data, do
//
//     final apiCategory = apiCategoryFromJson(jsonString);

part of '../firelamp.dart';

class ApiCategory {
  ApiCategory({
    this.idx,
    this.id,
    this.title,
    this.description,
    this.subcategories,
    this.pointPostCreate,
    this.pointPostDelete,
    this.pointCommentCreate,
    this.pointCommentDelete,
    this.banOnLimit,
    this.pointHourLimit,
    this.pointHourLimitCount,
    this.pointDailyLimitCount,
    this.listOnView,
    this.noOfPostsPerPage,
    this.mobilePostListWidget,
    this.mobilePostViewWidget,
    this.forumEditWidget,
    this.forumViewWidget,
    this.forumListHeaderWidget,
    this.forumListWidget,
    this.paginationWidget,
    this.noOfPagesOnNav,
    this.createdAt,
    this.updatedAt,
    this.postEditWidget,
    this.postListHeaderWidget,
    this.postListWidget,
    this.postViewWidget,
  });

  int idx;
  String id;
  String title;
  String description;
  List<String> subcategories;
  int pointPostCreate;
  int pointPostDelete;
  int pointCommentCreate;
  int pointCommentDelete;
  String banOnLimit;
  int pointHourLimit;
  int pointHourLimitCount;
  int pointDailyLimitCount;
  String listOnView;
  int noOfPostsPerPage;
  String mobilePostListWidget;
  String mobilePostViewWidget;
  String forumEditWidget;
  String forumViewWidget;
  String forumListHeaderWidget;
  String forumListWidget;
  String paginationWidget;
  int noOfPagesOnNav;
  int createdAt;
  int updatedAt;
  String postEditWidget;
  String postListHeaderWidget;
  String postListWidget;
  String postViewWidget;

  factory ApiCategory.fromJson(dynamic json) {
    if (json is List) return ApiCategory();
    if (json == null || json.length == 0) return ApiCategory();
    return ApiCategory(
      idx: int.parse("${json["idx"]}"),
      id: json["id"],
      title: json["title"],
      description: json["description"],
      subcategories: List<String>.from(json["subcategories"].map((x) => x)),
      pointPostCreate: int.parse("${json["POINT_POST_CREATE"]}"),
      pointPostDelete: int.parse("${json["POINT_POST_DELETE"]}"),
      pointCommentCreate: int.parse("${json["POINT_COMMENT_CREATE"]}"),
      pointCommentDelete: int.parse("${json["POINT_COMMENT_DELETE"]}"),
      banOnLimit: json["BAN_ON_LIMIT"],
      pointHourLimit: int.parse("${json["POINT_HOUR_LIMIT"]}"),
      pointHourLimitCount: int.parse("${json["POINT_HOUR_LIMIT_COUNT"]}"),
      pointDailyLimitCount: int.parse("${json["POINT_DAILY_LIMIT_COUNT"]}"),
      listOnView: json["listOnView"],
      noOfPostsPerPage: int.parse("${json["noOfPostsPerPage"]}"),
      mobilePostListWidget: json["mobilePostListWidget"],
      mobilePostViewWidget: json["mobilePostViewWidget"],
      forumEditWidget: json["forumEditWidget"],
      forumViewWidget: json["forumViewWidget"],
      forumListHeaderWidget: json["forumListHeaderWidget"],
      forumListWidget: json["forumListWidget"],
      paginationWidget: json["paginationWidget"],
      noOfPagesOnNav: int.parse("${json["noOfPagesOnNav"]}"),
      createdAt: int.parse("${json["createdAt"]}"),
      updatedAt: int.parse("${json["updatedAt"]}"),
      postEditWidget: json["postEditWidget"],
      postListHeaderWidget: json["postListHeaderWidget"],
      postListWidget: json["postListWidget"],
      postViewWidget: json["postViewWidget"],
    );
  }

  Map<String, dynamic> toJson() => {
        "idx": idx,
        "id": id,
        "title": title,
        "description": description,
        "subcategories": List<String>.from(subcategories.map((x) => x)),
        "POINT_POST_CREATE": pointPostCreate,
        "POINT_POST_DELETE": pointPostDelete,
        "POINT_COMMENT_CREATE": pointCommentCreate,
        "POINT_COMMENT_DELETE": pointCommentDelete,
        "BAN_ON_LIMIT": banOnLimit,
        "POINT_HOUR_LIMIT": pointHourLimit,
        "POINT_HOUR_LIMIT_COUNT": pointHourLimitCount,
        "POINT_DAILY_LIMIT_COUNT": pointDailyLimitCount,
        "listOnView": listOnView,
        "noOfPostsPerPage": noOfPostsPerPage,
        "mobilePostListWidget": mobilePostListWidget,
        "mobilePostViewWidget": mobilePostViewWidget,
        "forumEditWidget": forumEditWidget,
        "forumViewWidget": forumViewWidget,
        "forumListHeaderWidget": forumListHeaderWidget,
        "forumListWidget": forumListWidget,
        "paginationWidget": paginationWidget,
        "noOfPagesOnNav": noOfPagesOnNav,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "postEditWidget": postEditWidget,
        "postListHeaderWidget": postListHeaderWidget,
        "postListWidget": postListWidget,
        "postViewWidget": postViewWidget,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
