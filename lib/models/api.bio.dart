part of '../withcenter.dart';

class ApiBio {
  ApiBio({
    this.userId,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.birthdate,
    this.gender,
    this.height,
    this.weight,
    this.city,
    this.drinking,
    this.smoking,
    this.hobby,
    this.dateMethod,
    this.profilePhotoUrl,
    this.age,
    this.distance,
  });

  String userId;
  String name;
  String createdAt;
  String updatedAt;
  String birthdate;
  String gender;
  String height;
  String weight;
  String city;
  String drinking;
  String smoking;
  String hobby;
  String dateMethod;
  String profilePhotoUrl;

  String age;
  String distance;

  factory ApiBio.fromJson(Map<String, dynamic> json) {
    String age;
    String birthdate = json["birthdate"];
    if (birthdate == null || birthdate == '' || birthdate == '0')
      age = '0';
    else {
      final _yy = int.parse(birthdate.substring(0, 2));
      final _mm = int.parse(birthdate.substring(2, 4));
      final _dd = int.parse(birthdate.substring(4, 6));

      DateTime birthday = DateTime(_yy < 20 ? 2000 + _yy : 1900 + _yy, _mm, _dd);

      DateTime today = DateTime.now();

      AgeDuration _age;

      // Set the age of the user
      _age = Age.dateDifference(fromDate: birthday, toDate: today, includeToDate: false);

      age = _age.years.toString();
    }

    String dis;
    if (json['distance'] != null && json['distance'] != '') {
      final distance = double.parse(json['distance']);
      if (distance < 10) {
        dis = distance.round().toStringAsFixed(1);
      } else {
        dis = distance.round().toString();
      }
    }

    return ApiBio(
      userId: json["user_ID"],
      name: json["name"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      birthdate: json["birthdate"],
      gender: json["gender"],
      height: json["height"] == '0' ? '' : json["height"],
      weight: json["weight"] == '0' ? '' : json["weight"],
      city: json["city"],
      drinking: json["drinking"],
      smoking: json["smoking"],
      hobby: json["hobby"],
      dateMethod: json["dateMethod"],
      profilePhotoUrl: json['profile_photo_url'],
      age: age,
      distance: dis,
    );
  }

  Map<String, dynamic> toJson() => {
        "user_ID": userId,
        "name": name,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "birthdate": birthdate,
        "gender": gender,
        "height": height,
        "weight": weight,
        "city": city,
        "drinking": drinking,
        "smoking": smoking,
        "hobby": hobby,
        "dateMethod": dateMethod,
        "user_profile_photo": profilePhotoUrl,
        "age": age,
        "distance": distance,
      };
  @override
  String toString() {
    return toJson().toString();
  }
}
