part of '../firelamp.dart';

class ApiFile {
  ApiFile({
    this.url,
    this.idx,
    this.type,
    this.name,
    this.thumbnailUrl,
    this.taxonomy,
    this.entity,
    this.code,
  });

  String url;
  String idx;
  String type;
  String name;
  String thumbnailUrl;
  String taxonomy;
  String entity;
  String code;

  /// File upload percentage
  /// 업로드 퍼센티지 변수. 파일을 업로드 할 때, 여기에 업로드 퍼센티지를 기록 할 수 있다. 클라이언트에서만 사용됨.
  double percentage = 0.0;

  /// [exif] is not in use anymore by 2021. 01. 11.
  // Exif exif;

  factory ApiFile.fromJson(Map<String, dynamic> json) {
    // String url = Api.instance.thumbnailUrl;
    // url = url + '?src=${json['idx']}&w=360&h=360&f=jpeg&q=95';

    String url = Api.instance.thumbnailUrl(src: json['idx'], width: 360, quality: 95);

    // print('url: thumbnail: $url');
    return ApiFile(
      url: json["url"],
      idx: "${json["idx"]}",
      type: json["type"],
      name: json["name"],
      thumbnailUrl: url,
      taxonomy: json["taxonomy"],
      entity: "${json["entity"]}",
      code: json["code"],
    );
  }

  Map<String, dynamic> toJson() => {
        "url": url,
        "idx": idx,
        "type": type,
        "name": name,
        "thumbnialUrl": thumbnailUrl,
        "taxonomy": taxonomy,
        "entity": entity,
        "code": code,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
