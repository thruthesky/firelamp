import 'package:firelamp/firelamp.dart';

class ApiPostUser {
  final int idx;
  final String name;
  final String nickname;
  final String gender;
  final int photoIdx;
  final String photoUrl;

  ApiPostUser({this.idx, this.name, this.nickname, this.gender, this.photoIdx, this.photoUrl});

  factory ApiPostUser.fromJson(Map<String, dynamic> json) {
    if (json == null) return ApiPostUser();
    int photoIdx = int.parse("${json['photoIdx']}");
    String url;
    if (photoIdx > 0) {
      url = Api.instance.thumbnailUrl;
      url = url + '?src=$photoIdx}&w=100&h=100&f=jpeg&q=95';
    }
    return ApiPostUser(
      idx: int.parse("${json['idx']}"),
      name: json['name'],
      nickname: json['nickname'],
      photoIdx: photoIdx,
      photoUrl: url,
    );
  }

  Map toJson() {
    return {
      'idx': idx,
      'name': name,
      'nickname': nickname,
      'photoIdx': photoIdx,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
