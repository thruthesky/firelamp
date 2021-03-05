part of '../firelamp.dart';

enum CommentMode {
  none,
  edit,
  reply,
}

class ApiComment extends ApiForumBase {
  ApiComment({
    int idx,
    String rootIdx,
    String parentIdx,
    String userIdx,
    String subcategory,
    String path,
    String content,
    String profilePhotoUrl,
    String authorName,
    List<ApiFile> files,
    String createdAt,
    String updatedAt,
    String deletedAt,
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
          authorName: authorName,
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
