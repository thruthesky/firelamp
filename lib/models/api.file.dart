part of '../firelamp.dart';

class ApiFile {
  ApiFile({
    this.url,
    this.idx,
    this.mediaType,
    this.type,
    this.name,
    this.thumbnailUrl,
    // this.exif,
  });

  String url;
  int idx;
  String mediaType;
  String type;
  String name;
  String thumbnailUrl;

  /// [exif] is not in use anymore by 2021. 01. 11.
  // Exif exif;

  factory ApiFile.fromJson(Map<String, dynamic> json) => ApiFile(
        url: json["url"],
        idx: json["idx"],
        mediaType: json["media_type"],
        type: json["type"],
        name: json["name"],
        thumbnailUrl: json["thumbnail_url"],
        // exif: Exif.fromJson(json["exif"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "idx": idx,
        "media_type": mediaType,
        "type": type,
        "name": name,
        "thumbnail_url": thumbnailUrl,
        // "exif": exif.toJson(),
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

// class Exif {
//   Exif({
//     this.fileName,
//     this.fileDateTime,
//     this.fileSize,
//     this.fileType,
//     this.mimeType,
//     this.sectionsFound,
//     this.html,
//     this.height,
//     this.width,
//     this.isColor,
//     this.byteOrderMotorola,
//     this.orientation,
//     this.exifIfdPointer,
//     this.colorSpace,
//     this.exifImageWidth,
//     this.exifImageLength,
//   });

//   String fileName;
//   int fileDateTime;
//   int fileSize;
//   int fileType;
//   String mimeType;
//   String sectionsFound;
//   String html;
//   int height;
//   int width;
//   int isColor;
//   int byteOrderMotorola;
//   int orientation;
//   int exifIfdPointer;
//   int colorSpace;
//   int exifImageWidth;
//   int exifImageLength;

//   factory Exif.fromJson(Map<String, dynamic> json) => Exif(
//         fileName: json["FileName"],
//         fileDateTime: json["FileDateTime"],
//         fileSize: json["FileSize"],
//         fileType: json["FileType"],
//         mimeType: json["MimeType"],
//         sectionsFound: json["SectionsFound"],
//         html: json["html"],
//         height: json["Height"],
//         width: json["Width"],
//         isColor: json["IsColor"],
//         byteOrderMotorola: json["ByteOrderMotorola"],
//         orientation: json["Orientation"],
//         exifIfdPointer: json["Exif_IFD_Pointer"],
//         colorSpace: json["ColorSpace"],
//         exifImageWidth: json["ExifImageWidth"],
//         exifImageLength: json["ExifImageLength"],
//       );

//   Map<String, dynamic> toJson() => {
//         "FileName": fileName,
//         "FileDateTime": fileDateTime,
//         "FileSize": fileSize,
//         "FileType": fileType,
//         "MimeType": mimeType,
//         "SectionsFound": sectionsFound,
//         "html": html,
//         "Height": height,
//         "Width": width,
//         "IsColor": isColor,
//         "ByteOrderMotorola": byteOrderMotorola,
//         "Orientation": orientation,
//         "Exif_IFD_Pointer": exifIfdPointer,
//         "ColorSpace": colorSpace,
//         "ExifImageWidth": exifImageWidth,
//         "ExifImageLength": exifImageLength,
//       };
// }
