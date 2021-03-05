class ApiPointHistory {
  ApiPointHistory({
    this.idx,
    this.fromUserIdx,
    this.toUserIdx,
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
  int idx;
  int fromUserIdx;
  int toUserIdx;
  String reason;
  String taxonomy;
  int entity;
  int categoryIdx;
  int fromUserPointApply;
  int fromUserPointAfter;
  int toUserPointApply;
  int toUserPointAfter;
  int createdAt;
  int updatedAt;

  factory ApiPointHistory.fromJson(dynamic json) {
    return ApiPointHistory(
      idx: int.parse("${json['idx']}"),
      fromUserIdx: int.parse("${json['fromUserIdx']}"),
      toUserIdx: int.parse("${json['toUserIdx']}"),
      reason: json['reason'],
      taxonomy: json['taxonomy'],
      entity: int.parse("${json['entity']}"),
      categoryIdx: int.parse("${json['categoryIdx']}"),
      fromUserPointApply: int.parse("${json['fromUserPointApply']}"),
      fromUserPointAfter: int.parse("${json['fromUserPointAfter']}"),
      toUserPointApply: int.parse("${json['toUserPointApply']}"),
      toUserPointAfter: int.parse("${json['toUserPointAfter']}"),
      createdAt: int.parse("${json['createdAt']}"),
      updatedAt: int.parse("${json['updatedAt']}"),
    );
  }

  @override
  String toString() {
    return '';
  }
}
