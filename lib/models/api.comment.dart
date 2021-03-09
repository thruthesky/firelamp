part of '../firelamp.dart';

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
    this.content,
    this.files,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.depth,
    this.y,
    this.n,
    this.mode = CommentMode.none,
  }) {
    if (files == null) files = [];
    if (content == null) content = '';
  }

  Map<String, dynamic> data;
  int depth;
  int idx;
  int rootIdx;
  int parentIdx;
  int userIdx;
  ApiPostUser user;
  int categoryIdx;
  String subcategory;
  String path;
  String content;
  List<ApiFile> files;
  int createdAt;
  int updatedAt;
  int deletedAt;
  int y;
  int n;

  /// [mode] becomes
  /// - `CommentMode.edit` when the comment is in edit mode.
  /// - `CommentMode.reply` when the comment will have a form for creating a child comment.
  /// - `CommentMode.none` string for nothing.
  CommentMode mode;

  bool get isMine => userIdx == Api.instance.userIdx;
  bool get isNotMine => !isMine;

  bool get isDeleted => deletedAt != 0;

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
      idx: int.parse(
          "${json['idx']}"), //    json["idx"] is String ? int.parse(json["idx"]) : json["idx"],
      rootIdx: int.parse("${json['rootIdx']}"),
      parentIdx: int.parse("${json['parentIdx']}"),
      subcategory: json['subcategory'],
      userIdx: int.parse("${json['userIdx']}"),
      user: ApiPostUser.fromJson(json['user']),
      path: json['path'],
      content: json['content'] ?? '',
      files: json["files"] == null || json["files"] == ''
          ? []
          : List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
      depth: int.parse("${json['depth'] ?? 1}"),
      createdAt: int.parse("${json['createdAt']}"),
      updatedAt: int.parse("${json['updatedAt']}"),
      deletedAt: int.parse("${json['deletedAt']}"),
      y: int.parse("${json['Y']}"),
      n: int.parse("${json['N']}"),
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
        "content": content,
        "files": files,
        "depth": depth,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
        "y": y,
        "n": n,
      };
  @override
  String toString() {
    return toJson().toString();
  }
}
