part of '../firelamp.dart';

enum CommentMode {
  none,
  edit,
  reply,
}

class ApiComment {
  ApiComment({
    this.commentId,
    this.commentPostId,
    this.commentParent,
    this.depth,
    this.userId,
    this.commentAuthor,
    this.commentContent,
    this.commentContentAutop,
    this.commentDate,
    this.files,
    this.userPhoto,
    this.shortDateTime,
    this.mode = CommentMode.none,
  }) {
    if (files == null) files = [];
    if (commentContent == null) commentContent = '';
  }

  String commentId;
  String commentPostId;
  String commentParent;
  int depth;
  String userId;
  String commentAuthor;
  String commentContent;
  String commentContentAutop;
  DateTime commentDate;
  List<ApiFile> files;
  String userPhoto;
  String shortDateTime;

  /// [mode] becomes
  /// - `CommentMode.edit` when the comment is in edit mode.
  /// - `CommentMode.reply` when the comment will have a form for creating a child comment.
  /// - `CommentMode.none` string for nothing.
  CommentMode mode;

  bool get isMine => userId == Api.instance.id;
  bool get isNotMine => !isMine;

  factory ApiComment.fromJson(Map<String, dynamic> json) => ApiComment(
        commentId: json["comment_ID"],
        commentPostId: json["comment_post_ID"],
        commentParent: json["comment_parent"],
        depth: json["depth"] ?? 1,
        userId: json["user_id"],
        commentAuthor: json["comment_author"],
        commentContent: json["comment_content"],
        commentContentAutop: json["comment_content_autop"],
        commentDate: DateTime.parse(json["comment_date"]),
        files: List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
        userPhoto: json["user_photo"] ?? '',
        shortDateTime: json["short_date_time"],
      );

  Map<String, dynamic> toJson() => {
        "comment_ID": commentId,
        "comment_post_ID": commentPostId,
        "comment_parent": commentParent,
        "depth": depth,
        "user_id": userId,
        "comment_author": commentAuthor,
        "comment_content": commentContent,
        "comment_content_autop": commentContentAutop,
        "comment_date": commentDate.toIso8601String(),
        "files": List<dynamic>.from(files.map((x) => x)),
        "user_photo": userPhoto,
        "short_date_time": shortDateTime,
      };
  @override
  String toString() {
    return toJson().toString();
  }
}
