import 'package:firelamp/firelamp.dart';

class ApiShortUser {
  final int idx;
  final String name;
  final String nickname;
  final String gender;
  final int photoIdx;
  final String photoUrl;
  final String firebaseUid;

  ApiShortUser({
    this.idx,
    this.name,
    this.nickname,
    this.gender,
    this.photoIdx,
    this.photoUrl,
    this.firebaseUid,
  });

  factory ApiShortUser.fromJson(dynamic json) {
    if (json == null) return ApiShortUser();

    // 사용자 정보가 없는 경우, Map 대신 빈 배열(List)로 들어온다.
    if (json is List) return ApiShortUser();

    int photoIdx = int.parse("${json['photoIdx'] ?? 0}");
    String url;
    if (photoIdx > 0) {
      // url = Api.instance.thumbnailUrl;
      // url = url + '?src=$photoIdx&w=100&h=100&f=jpeg&q=95';
      url =
          Api.instance.thumbnailUrl(src: photoIdx.toString(), width: 100, height: 100, quality: 95);
    }
    return ApiShortUser(
      idx: int.parse("${json['idx']}"),
      name: json['name'],
      nickname: json['nickname'],
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
