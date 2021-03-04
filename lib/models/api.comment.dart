part of '../firelamp.dart';

enum CommentMode {
  none,
  edit,
  reply,
}

class ApiComment {
  ApiComment({
    this.idx,
    this.rootIdx,
    this.parentIdx,
    this.userIdx,
    this.subcategory,
    this.path,
    this.content,
    this.profilePhotoUrl,
    this.authorName,
    this.files,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.depth,
    this.mode = CommentMode.none,
  }) {
    if (files == null) files = [];
    if (content == null) content = '';
  }

  /// updates
  int idx;
  String rootIdx;
  String parentIdx;
  String userIdx;
  String subcategory;
  String path;
  String content;
  String profilePhotoUrl;
  String authorName;
  List<ApiFile> files;
  String createdAt;
  String updatedAt;
  String deletedAt;

  int depth;

  /// [mode] becomes
  /// - `CommentMode.edit` when the comment is in edit mode.
  /// - `CommentMode.reply` when the comment will have a form for creating a child comment.
  /// - `CommentMode.none` string for nothing.
  CommentMode mode;

  bool get isMine => userIdx == Api.instance.idx;
  bool get isNotMine => !isMine;

  bool get isDeleted => deletedAt != '0';

  factory ApiComment.fromJson(Map<String, dynamic> json) => ApiComment(
        idx: json["idx"] is String ? int.parse(json["idx"]) : json["idx"],
        rootIdx: json['rootIdx'],
        parentIdx: json['parentIdx'],
        subcategory: json['subcategory'],
        userIdx: json['userIdx'],
        path: json['path'],
        content: json['content'] ?? '',
        profilePhotoUrl: json['profilePhotoUrl'] ?? '',
        authorName: json['authorName'],

        files: json["files"] == null || json["files"] == ''
            ? []
            : List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),

        depth: json["depth"] ?? 1,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        deletedAt: json['deletedAt'],
      );

  Map<String, dynamic> toJson() => {
        "idx": idx,
        "rootIdx": rootIdx,
        "parentIdx": parentIdx,
        "subcategory": subcategory,
        "userIdx": userIdx,
        "path": path,
        "content": content,
        "files": files,
        "profilePhotoUrl": profilePhotoUrl,
        "authorName": authorName,
        "depth": depth,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
      };
  @override
  String toString() {
    return toJson().toString();
  }
}
