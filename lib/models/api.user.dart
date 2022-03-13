part of '../firelamp.dart';

class ApiUser {
  Map<String, dynamic> data;
  bool admin;
  String nickname;
  String firstName;
  String lastName;
  String locale;
  String autoLoginYn;
  String autoStatusCheck;
  String plid;
  String agegroup;
  String point;
  String token;
  String score;
  String recommendation;

  String get age {
    return calAge(birthdate);
  }

  String get ageGroup {
    String firstChar = this.age.split('').first;
    if (firstChar == '0') return firstChar;
    return firstChar + '0';
  }

  String gender;
  String foreign;
  String telcoCd;
  String ci;
  String phoneNo;
  String name;
  String birthday;
  String birthdate;

  String idx;
  String email;
  String firebaseUid;
  String userRegistered;
  String sessionId;

  String createdAt;
  String updatedAt;

  /// [mode] is used only when `loginOrRegister` method is being invoked.
  /// It is one of `login` or `register`.
  String mode;
  // String primaryPhotoUrl;
  // String get fullName => name;
  // String dateMethod;
  // String height;
  // String weight;
  // String city;
  // String hobby;
  // String drinking;
  // String smoking;

  String photoIdx;
  String photoUrl;

  bool get male => gender == 'M';
  bool get female => gender == 'F';

  String get nicknameOrName {
    if (nickname != null && nickname != '') {
      return nickname;
    }
    if (name != null && name != '') {
      return name;
    }
    return '...';
  }

  ApiUser({
    this.admin = false,
    this.nickname,
    this.firstName,
    this.lastName,
    this.locale,
    this.autoLoginYn,
    this.autoStatusCheck,
    this.plid,
    this.agegroup,
    this.gender,
    this.foreign,
    this.telcoCd,
    this.ci,
    this.phoneNo,
    this.name,
    this.birthday,
    this.birthdate,
    this.idx,
    this.email,
    this.firebaseUid,
    this.userRegistered,
    this.sessionId,
    this.mode,
    this.photoIdx,
    this.photoUrl,
    this.point,
    this.token,
    this.score,
    this.recommendation,
    this.createdAt,
    this.updatedAt,
  });

  ApiUser.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    data = json;
    admin = json['admin'] == 'Y' ? true : false;
    nickname = json['nickname'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    locale = json['locale'];
    autoLoginYn = json['autoLoginYn'];
    autoStatusCheck = json['autoStatusCheck'];
    plid = json['plid'];
    agegroup = json['agegroup'];
    gender = json['gender'];
    foreign = json['foreign'];
    telcoCd = json['telcoCd'];
    ci = json['ci'];
    phoneNo = json['phoneNo'];
    name = json['name'];
    birthday = json['birthday'];
    birthdate = json['birthdate'].toString();
    idx = "${json['idx']}";
    email = json['email'];
    firebaseUid = json['firebaseUid'];
    userRegistered = json['user_registered'];
    sessionId = json['sessionId'];
    mode = json['mode'];
    photoIdx = "${json['photoIdx'] ?? 0}";

    // 만약, 사용자가 프로필 사진을 업로드 했으면, 그것을 쓰고 아니면,
    if (photoIdx.toInt > 0) {
      photoUrl = Api.instance
          .thumbnailUrl(src: photoIdx, width: 100, height: 100, quality: 95, original: true);
    } else if (json['photoUrl'] != null) {
      // 아니면, meta 에 기록된 photoUrl 을 사용한다.
      photoUrl = json['photoUrl'];
    }
    point = "${json['point']}";
    token = "${json['atoken'] ?? 0}";
    score = "${int.parse(json['point']) + int.parse(json['atoken']) * 100}";
    recommendation = "${json['recommendation'] ?? ''}";
    createdAt = "${json['createdAt'] ?? 0}";
    updatedAt = "${json['updatedAt'] ?? 0}";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin'] = this.admin;
    data['nickname'] = this.nickname;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['locale'] = this.locale;
    data['autoLoginYn'] = this.autoLoginYn;
    data['autoStatusCheck'] = this.autoStatusCheck;
    data['plid'] = this.plid;
    data['agegroup'] = this.agegroup;
    data['gender'] = this.gender;
    data['foreign'] = this.foreign;
    data['telcoCd'] = this.telcoCd;
    data['ci'] = this.ci;
    data['phoneNo'] = this.phoneNo;
    data['name'] = this.name;
    data['birthday'] = this.birthday;
    data['birthdate'] = this.birthdate;
    data['idx'] = this.idx;
    data['email'] = this.email;
    data['firebaseUid'] = this.firebaseUid;
    data['user_registered'] = this.userRegistered;
    data['sessionId'] = this.sessionId;
    data['mode'] = this.mode;
    data['photoIdx'] = this.photoIdx;
    data['photoUrl'] = this.photoUrl;
    data['point'] = this.point;
    data['atoken'] = this.token;
    data['recommendation'] = this.recommendation;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
