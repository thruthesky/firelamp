import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// The [imageUpload] is only a sample function to illustrate how you can upload a photo.
/// You may copy this and change whatever to meet your design goal.
/// [onProgress] will be called many times with percentage value.
Future<ApiFile> imageUpload({
  int quality = 90,
  Function? onProgress,
  String taxonomy = '',
  int entity = 0,
  String code = '',
  bool deletePreviousUpload = false,
}) async {
  ImageSource? re = await Get.bottomSheet(
    Container(
      color: Colors.white,
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.camera_alt, size: 28),
                title: Text('take photo from camera'.tr),
                onTap: () => Get.back(result: ImageSource.camera)),
            ListTile(
                leading: Icon(Icons.image, size: 28),
                title: Text('get photo from gallery'.tr),
                onTap: () => Get.back(result: ImageSource.gallery)),
            ListTile(
                leading: Icon(Icons.cancel, size: 28), title: Text('cancel'.tr), onTap: () => Get.back(result: null)),
          ],
        ),
      ),
    ),
  );
  if (re == null) throw ERROR_IMAGE_NOT_SELECTED;

  print('code: $code in function.dart::imageUpload');
  return Api.instance!.takeUploadFile(
    source: re,
    quality: quality,
    onProgress: onProgress,
    taxonomy: taxonomy,
    entity: entity,
    code: code,
    deletePreviousUpload: deletePreviousUpload,
  );
}
