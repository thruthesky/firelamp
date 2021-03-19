import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

Future<ApiFile> imageUpload({int quality = 90, Function onProgress}) async {
  /// Ask user
  final re = await Get.bottomSheet(
    Container(
      color: Colors.white,
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.music_note),
                title: Text('take photo from camera'),
                onTap: () => Get.back(result: ImageSource.camera)),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('get photo from gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('cancel'),
              onTap: () => Get.back(result: null),
            ),
          ],
        ),
      ),
    ),
  );
  if (re == null) throw ERROR_IMAGE_NOT_SELECTED;

  return Api.instance
      .takeUploadFile(source: re, quality: quality, onProgress: onProgress);
}
