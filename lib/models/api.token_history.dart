part of '../firelamp.dart';

class ApiTokenHistory {
  ApiTokenHistory({
    this.idx,
    this.userIdx,
    this.reason,
    this.pointAfterApply,
    this.pointApply,
    this.tokenApply,
    this.tokenAfterApply,
    this.createdAt,
    this.updatedAt,
  });
  String idx;
  String userIdx;
  String reason;
  String pointAfterApply;
  String pointApply;
  String tokenApply;
  String tokenAfterApply;
  String createdAt;
  String updatedAt;

  factory ApiTokenHistory.fromJson(dynamic json) {
    return ApiTokenHistory(
      idx: "${json['idx']}",
      userIdx: "${json['userIdx']}",
      reason: json['reason'],
      pointAfterApply: "${json['pointAfterApply']}",
      pointApply: "${json['pointApply']}",
      tokenApply: "${json['tokenApply']}",
      tokenAfterApply: "${json['tokenAfterApply']}",
      createdAt: "${json['createdAt']}",
      updatedAt: "${json['updatedAt']}",
    );
  }

  @override
  String toString() {
    return "ApiTokenHistory(${toJson()})";
  }

  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'userIdx': userIdx,
      'reason': reason,
      'pointAfterApply': pointAfterApply,
      'pointApply': pointApply,
      'tokenApply': tokenApply,
      'tokenAfterApply': tokenAfterApply,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
