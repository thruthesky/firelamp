part of '../firelamp.dart';

class ApiFile {
  ApiFile({
    this.url,
    this.idx,
    this.type,
    this.name,
    this.thumbnailUrl,
  });

  String url;
  int idx;
  String type;
  String name;
  String thumbnailUrl;

  /// [exif] is not in use anymore by 2021. 01. 11.
  // Exif exif;

  factory ApiFile.fromJson(Map<String, dynamic> json) {
    String url = Api.instance.thumbnailUrl;
    url = url + '?src=${json['idx']}&w=100&h=100&f=jpeg&q=95';

    return ApiFile(
      url: json["url"],
      idx: int.parse("${json["idx"]}"),
      type: json["type"],
      name: json["name"],
      thumbnailUrl: url,
    );
  }

  Map<String, dynamic> toJson() => {
        "url": url,
        "idx": idx,
        "type": type,
        "name": name,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
