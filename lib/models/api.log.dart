part of '../firelamp.dart';

class ApiLog {
  ApiLog({
    this.idx,
    this.userIdx,
    this.point,
    this.token,
    this.createdAt,
    this.updatedAt,
  });
  String idx;
  String userIdx;
  String point;
  String token;
  String createdAt;
  String updatedAt;

  factory ApiLog.fromJson(dynamic json) {
    return ApiLog(
      idx: "${json['idx']}",
      userIdx: "${json['userIdx']}",
      point: "${json['point']}",
      token: "${json['atoken']}",
      createdAt: "${json['createdAt']}",
      updatedAt: "${json['updatedAt']}",
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'userIdx': userIdx,
      'point': point,
      'atoken': token,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
