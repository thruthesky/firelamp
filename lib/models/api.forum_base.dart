part of '../firelamp.dart';

class ApiForumBase {
  ApiForumBase({
    // this.data,
    this.idx,
    this.userIdx,
    this.rootIdx,
    this.parentIdx,
    this.categoryIdx,
    this.subcategory,
    this.path,
    this.content,
    this.authorName,
    this.profilePhotoUrl,
    this.files,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) {
    if (files == null) files = [];
    if (content == null) content = '';
  }

  dynamic data;

  int idx;
  String userIdx;
  String rootIdx;
  String parentIdx;
  String categoryIdx;
  String subcategory;
  String path;

  String content;
  String authorName;
  String profilePhotoUrl;

  /// TODO:
  List<ApiFile> files;

  String createdAt;
  String updatedAt;
  String deletedAt;

  bool get isMine => userIdx == Api.instance.userIdx;
  bool get isNotMine => !isMine;

  bool get isDeleted => deletedAt != '0';
}
