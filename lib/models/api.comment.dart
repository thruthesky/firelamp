part of '../firelamp.dart';

enum CommentMode {
  none,
  edit,
  reply,
}

class ApiComment extends ApiForumBase {
  ApiComment({
    int idx,
    int rootIdx,
    int parentIdx,
    int userIdx,
    String subcategory,
    String path,
    String content,
    String profilePhotoUrl,
    List<ApiFile> files,
    int createdAt,
    int updatedAt,
    int deletedAt,
    this.depth,
    this.mode = CommentMode.none,
  }) : super(
          idx: idx,
          rootIdx: rootIdx,
          parentIdx: parentIdx,
          userIdx: userIdx,
          subcategory: subcategory,
          path: path,
          content: content,
          profilePhotoUrl: profilePhotoUrl,
          files: files,
          createdAt: createdAt,
          updatedAt: updatedAt,
          deletedAt: deletedAt,
        );

  int depth;

  /// [mode] becomes
  /// - `CommentMode.edit` when the comment is in edit mode.
  /// - `CommentMode.reply` when the comment will have a form for creating a child comment.
  /// - `CommentMode.none` string for nothing.
  CommentMode mode;

  factory ApiComment.fromJson(Map<String, dynamic> json) => ApiComment(
        idx: int.parse(
            "${json['idx']}"), //    json["idx"] is String ? int.parse(json["idx"]) : json["idx"],
        rootIdx: int.parse("${json['rootIdx']}"),
        parentIdx: int.parse("${json['parentIdx']}"),
        subcategory: json['subcategory'],
        userIdx: int.parse("${json['userIdx']}"),
        path: json['path'],
        content: json['content'] ?? '',
        profilePhotoUrl: json['profilePhotoUrl'] ?? '',
        files: json["files"] == null || json["files"] == ''
            ? []
            : List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
        depth: int.parse("${json['depth'] ?? 1}"),
        createdAt: int.parse("${json['createdAt']}"),
        updatedAt: int.parse("${json['updatedAt']}"),
        deletedAt: int.parse("${json['deletedAt']}"),
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
