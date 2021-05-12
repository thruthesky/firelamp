import 'dart:convert';

class ApiFriend {
  final String idx;
  final String myIdx;
  final String otherIdx;
  final String block;
  final String reason;
  final String createdAt;
  final String updatedAt;
  ApiFriend({
    this.idx,
    this.myIdx,
    this.otherIdx,
    this.block,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  ApiFriend copyWith({
    String idx,
    String myIdx,
    String otherIdx,
    String block,
    String reason,
    String createdAt,
    String updatedAt,
  }) {
    return ApiFriend(
      idx: idx ?? this.idx,
      myIdx: myIdx ?? this.myIdx,
      otherIdx: otherIdx ?? this.otherIdx,
      block: block ?? this.block,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'myIdx': myIdx,
      'otherIdx': otherIdx,
      'block': block,
      'reason': reason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ApiFriend.fromMap(Map<String, dynamic> map) {
    return ApiFriend(
      idx: map['idx'],
      myIdx: map['myIdx'],
      otherIdx: map['otherIdx'],
      block: map['block'],
      reason: map['reason'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiFriend.fromJson(String source) => ApiFriend.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ApiFriend(idx: $idx, myIdx: $myIdx, otherIdx: $otherIdx, block: $block, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiFriend &&
        other.idx == idx &&
        other.myIdx == myIdx &&
        other.otherIdx == otherIdx &&
        other.block == block &&
        other.reason == reason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return idx.hashCode ^
        myIdx.hashCode ^
        otherIdx.hashCode ^
        block.hashCode ^
        reason.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
