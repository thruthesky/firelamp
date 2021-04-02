import 'package:firelamp/firelamp.dart';

class ApiShortUser {
  final String idx;
  final String name;
  final String nickname;
  final String gender;
  final String birthdate;
  final String point;
  final String photoIdx;
  final String photoUrl;
  final String firebaseUid;

  ApiShortUser({
    this.idx,
    this.name,
    this.nickname,
    this.gender,
    this.birthdate,
    this.point,
    this.photoIdx,
    this.photoUrl,
    this.firebaseUid,
  });

  factory ApiShortUser.fromJson(dynamic json) {
    if (json == null) return ApiShortUser();

    // 사용자 정보가 없는 경우, Map 대신 빈 배열(List)로 들어온다.
    if (json is List) return ApiShortUser();

    String photoIdx = "${json['photoIdx']}";
    String url;
    if (photoIdx != '' && photoIdx != '0') {
      url = Api.instance.thumbnailUrl(src: photoIdx, width: 100, height: 100, quality: 95);
    }
    return ApiShortUser(
      idx: "${json['idx']}",
      name: json['name'],
      nickname: json['nickname'],
      gender: json['gender'],
      birthdate: "${json['birthdate']}",
      point: "${json['point']}",
      photoIdx: photoIdx,
      photoUrl: url,
      firebaseUid: json['firebaseUid'],
    );
  }

  Map toJson() {
    return {
      'idx': idx,
      'name': name,
      'nickname': nickname,
      'gender': gender,
      'birthdate': birthdate,
      'point': point,
      'photoIdx': photoIdx,
      'photoUrl': photoUrl,
      'firebaseUid': firebaseUid,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
