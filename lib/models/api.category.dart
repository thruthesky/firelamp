// To parse this JSON data, do
//
//     final apiCategory = apiCategoryFromJson(jsonString);
//
part of '../firelamp.dart';

class ApiCategory {
  ApiCategory({
    this.idx,
    this.id,
    this.title,
    this.description,
    this.subcategories,
    this.orgSubcategories,
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

  String idx;
  String id;
  String title;
  String description;
  List<String> subcategories;

  /// 콤마로 분리된 문자열을 가지고 있는 원래, 카테고리 문자열.
  String orgSubcategories;
  String pointPostCreate;
  String pointPostDelete;
  String pointCommentCreate;
  String pointCommentDelete;
  String banOnLimit;
  String pointHourLimit;
  String pointHourLimitCount;
  String pointDailyLimitCount;
  String listOnView;
  String noOfPostsPerPage;
  String mobilePostListWidget;
  String mobilePostViewWidget;
  String forumEditWidget;
  String forumViewWidget;
  String forumListHeaderWidget;
  String forumListWidget;
  String paginationWidget;
  String noOfPagesOnNav;
  String createdAt;
  String updatedAt;
  String postEditWidget;
  String postListHeaderWidget;
  String postListWidget;
  String postViewWidget;

  factory ApiCategory.fromJson(dynamic json) {
    if (json is List) return ApiCategory();
    if (json == null || json.length == 0) return ApiCategory();
    return ApiCategory(
      idx: "${json["idx"]}",
      id: json["id"],
      title: json["title"],
      description: json["description"],
      subcategories: List<String>.from(json["subcategories"].map((x) => x)),
      orgSubcategories: List<String>.from(json["subcategories"].map((x) => x)).join(','),
      pointPostCreate: "${json["POINT_POST_CREATE"]}",
      pointPostDelete: "${json["POINT_POST_DELETE"]}",
      pointCommentCreate: "${json["POINT_COMMENT_CREATE"]}",
      pointCommentDelete: "${json["POINT_COMMENT_DELETE"]}",
      banOnLimit: json["BAN_ON_LIMIT"],
      pointHourLimit: "${json["POINT_HOUR_LIMIT"]}",
      pointHourLimitCount: "${json["POINT_HOUR_LIMIT_COUNT"]}",
      pointDailyLimitCount: "${json["POINT_DAILY_LIMIT_COUNT"]}",
      listOnView: json["listOnView"],
      noOfPostsPerPage: "${json["noOfPostsPerPage"]}",
      mobilePostListWidget: json["mobilePostListWidget"],
      mobilePostViewWidget: json["mobilePostViewWidget"],
      forumEditWidget: json["forumEditWidget"],
      forumViewWidget: json["forumViewWidget"],
      forumListHeaderWidget: json["forumListHeaderWidget"],
      forumListWidget: json["forumListWidget"],
      paginationWidget: json["paginationWidget"],
      noOfPagesOnNav: "${json["noOfPagesOnNav"]}",
      createdAt: "${json["createdAt"]}",
      updatedAt: "${json["updatedAt"]}",
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

  /// Returns a map of category data to save.
  Map<String, dynamic> toSave() => {
        "title": title,
        "description": description,
        "subcategories": orgSubcategories,
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
