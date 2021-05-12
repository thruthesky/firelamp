import 'package:firelamp/firelamp.dart';

class ApiPointHistory {
  ApiPointHistory({
    this.idx,
    this.fromUserIdx,
    this.fromUser,
    this.toUserIdx,
    this.toUser,
    this.reason,
    this.taxonomy,
    this.entity,
    this.categoryIdx,
    this.fromUserPointApply,
    this.fromUserPointAfter,
    this.toUserPointApply,
    this.toUserPointAfter,
    this.createdAt,
    this.updatedAt,
  });
  String idx;
  String fromUserIdx;
  ApiShortUser fromUser;
  String toUserIdx;
  ApiShortUser toUser;
  String reason;
  String taxonomy;
  String entity;
  String categoryIdx;
  String fromUserPointApply;
  String fromUserPointAfter;
  String toUserPointApply;
  String toUserPointAfter;
  String createdAt;
  String updatedAt;

  factory ApiPointHistory.fromJson(dynamic json) {
    return ApiPointHistory(
      idx: "${json['idx']}",
      fromUserIdx: "${json['fromUserIdx']}",
      fromUser: ApiShortUser.fromJson(json['fromUser']),
      toUserIdx: "${json['toUserIdx']}",
      toUser: ApiShortUser.fromJson(json['toUser']),
      reason: json['reason'],
      taxonomy: json['taxonomy'],
      entity: "${json['entity']}",
      categoryIdx: "${json['categoryIdx']}",
      fromUserPointApply: "${json['fromUserPointApply']}",
      fromUserPointAfter: "${json['fromUserPointAfter']}",
      toUserPointApply: "${json['toUserPointApply']}",
      toUserPointAfter: "${json['toUserPointAfter']}",
      createdAt: "${json['createdAt']}",
      updatedAt: "${json['updatedAt']}",
    );
  }

  @override
  String toString() {
    return '';
  }
}
