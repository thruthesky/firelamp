import 'package:firelamp/firelamp.dart';

enum CommentMode {
  none,
  edit,
  reply,
}

class ApiComment {
  ApiComment({
    this.data,
    this.idx,
    this.rootIdx,
    this.parentIdx,
    this.userIdx,
    this.user,
    this.categoryIdx,
    this.subcategory,
    this.path,
    this.title,
    this.content,
    this.files,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.depth,
    this.y,
    this.n,
    this.mode = CommentMode.none,
    this.shortDateTime,
  }) {
    if (files == null) files = [];
    if (content == null) content = '';
  }

  Map<String, dynamic> data;
  String depth;
  String idx;
  String rootIdx;
  String parentIdx;
  String userIdx;
  ApiShortUser user;
  String categoryIdx;
  String subcategory;
  String path;

  /// The [title] is the title of the comment. It may be used if needed.
  String title;
  String content;
  List<ApiFile> files;
  String createdAt;
  String updatedAt;
  String deletedAt;
  String y;
  String n;

  String shortDateTime;

  /// [mode] becomes
  /// - `CommentMode.edit` when the comment is in edit mode.
  /// - `CommentMode.reply` when the comment will have a form for creating a child comment.
  /// - `CommentMode.none` string for nothing.
  CommentMode mode;

  bool get isMine => userIdx == Api.instance.userIdx;
  bool get isNotMine => !isMine;

  bool get isDeleted => deletedAt.toInt != 0;

  bool get isEdit => idx != null && idx.toInt > 0;
  bool get isCreate => !isEdit;

  String get authorName {
    return user.nickname.isNotEmpty ? user.nickname : user.name;
  }

  /// Get short name for display
  String get shortName {
    return authorName.length < 10 ? authorName : authorName.substring(0, 9);
  }

  factory ApiComment.fromJson(Map<String, dynamic> json) {
    return ApiComment(
      data: json,
      idx: "${json['idx']}", //    json["idx"] is String ? int.parse(json["idx"]) : json["idx"],
      rootIdx: "${json['rootIdx']}",
      parentIdx: "${json['parentIdx']}",
      subcategory: json['subcategory'],
      userIdx: "${json['userIdx']}",
      user: ApiShortUser.fromJson(json['user']),
      path: json['path'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      files: json["files"] == null || json["files"] == ''
          ? []
          : List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
      depth: "${json['depth'] ?? 1}",
      createdAt: "${json['createdAt']}",
      updatedAt: "${json['updatedAt']}",
      deletedAt: "${json['deletedAt']}",
      y: "${json['Y']}",
      n: "${json['N']}",
      shortDateTime: json['shortDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "idx": idx,
        "rootIdx": rootIdx,
        "parentIdx": parentIdx,
        "subcategory": subcategory,
        "userIdx": userIdx,
        "user": user.toString(),
        "path": path,
        "title": title,
        "content": content,
        "files": files,
        "depth": depth,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
        "y": y,
        "n": n,
        "shortDateTime": shortDateTime,
      };
  @override
  String toString() {
    return toJson().toString();
  }
}
