import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/app_photo_viewer.dart';
import 'package:firelamp/widgets/app_video_viewer.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// The [imageUpload] is only a sample function to illustrate how you can upload a photo.
/// You may copy this and change whatever to meet your design goal.
/// [onProgress] will be called many times with percentage value.
Future<ApiFile> imageUpload({
  int quality = 90,
  Function onProgress,
  String taxonomy = '',
  int entity = 0,
  String code = '',
  bool deletePreviousUpload = false,
}) async {
  ImageSource re;
  if (kIsWeb) {
    re = ImageSource.gallery;
  } else {
    /// Ask user for mobile
    re = await Get.bottomSheet(
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
                  leading: Icon(Icons.cancel, size: 28),
                  title: Text('cancel'.tr),
                  onTap: () => Get.back(result: null)),
            ],
          ),
        ),
      ),
    );
    // if (re == null) throw ERROR_IMAGE_NOT_SELECTED;
  }
  print('code: $code in function.dart::imageUpload');
  return Api.instance.takeUploadFile(
    source: re,
    quality: quality,
    onProgress: onProgress,
    taxonomy: taxonomy,
    entity: entity,
    code: code,
    deletePreviousUpload: deletePreviousUpload,
  );
}

Future<ApiFile> fileUpload({
  int quality = 90,
  Function onProgress,
  String taxonomy = '',
  int entity = 0,
  String code = '',
  bool deletePreviousUpload = false,
  bool isVideo = false,
}) async {
  ImageSource re;
  if (kIsWeb) {
    re = ImageSource.gallery;
  } else {
    /// Ask user for mobile
    re = await Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library, size: 28),
                  title: Text('사진 앨범'),
                  onTap: () => Get.back(result: ImageSource.gallery)),
              ListTile(
                  leading: Icon(Icons.camera_alt, size: 28),
                  title: Text('카메라'),
                  onTap: () => Get.back(result: ImageSource.camera)),
              // ListTile(
              //     leading: Icon(Icons.video_library, size: 28),
              //     title: Text('비디오 앨범'),
              //     onTap: () {
              //       isVideo = true;
              //       return Get.back(result: ImageSource.gallery);
              //     }),
              // ListTile(
              //     leading: Icon(Icons.videocam, size: 28),
              //     title: Text('비디오'),
              //     onTap: () {
              //       isVideo = true;
              //       return Get.back(result: ImageSource.camera);
              //     }),
              ListTile(
                  leading: Icon(Icons.cancel, size: 28),
                  title: Text('cancel'.tr),
                  onTap: () {
                    Get.back(result: null);
                  }),
            ],
          ),
        ),
      ),
    );
    // print('imageUpload: $re');
    // print('imageUpload isVideo: $isVideo');
    // if (re == null) throw ERROR_IMAGE_NOT_SELECTED;
  }
  print('code: $code in function.dart::imageUpload');
  return Api.instance.takeUploadFile(
    isVideo: isVideo,
    source: re,
    quality: quality,
    onProgress: onProgress,
    taxonomy: taxonomy,
    entity: entity,
    code: code,
    deletePreviousUpload: deletePreviousUpload,
  );
}

class FileViewData extends StatefulWidget {
  const FileViewData({Key key, this.file}) : super(key: key);
  final ApiFile file;

  @override
  _FileViewDataState createState() => _FileViewDataState();
}

class _FileViewDataState extends State<FileViewData> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.network(widget.file.url);
    await Future.wait([
      videoPlayerController.initialize(),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isImageUrl(widget.file.url)) {
      return GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Space.xs),
          child: CachedImage(
            widget.file.url,
            onLoadComplete: () {
              // ChatRoom.instance.onImageLoadComplete(widget.file);
            },
          ),
        ),
        onTap: () {
          // print(widget.message);
          ApiFile file = ApiFile.fromJson({'url': widget.file.url, 'idx': widget.file.idx});
          Get.dialog(AppPhotoViewer([file]));
        },
      );
    } else if (isMovie(widget.file.url)) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Center(
            child: videoPlayerController.value != null
                ? AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio * 1.2,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(Space.xsm),
                        child: VideoPlayer(videoPlayerController)),
                  )
                : Container(),
          ),
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: Space.xxl,
              ),
              onTap: () {
                ApiFile file = ApiFile.fromJson({'url': widget.file.url, 'idx': widget.file.idx});
                Get.dialog(AppVideoViewer([file]));
              }),
        ],
      );
    } else if (widget.file.url.toLowerCase().startsWith('http')) {
      // @todo 첨부 파일. 다운로드 할 수 있도록 할 것.

      // widget.file.url = ' .. 첨부 파일!! 다운로드 할 것. .. ' + widget.file.url;
      // return Text(
      //   ChatRoom.instance.text(widget.file),
      //   textAlign: TextAlign.left,
      //   style: TextStyle(color: itsudaDarker),
      // );
    }
    return Text('');
    // return Text(
    //   ChatRoom.instance.text(widget.file),
    //   textAlign: TextAlign.left,
    //   style: TextStyle(color: itsudaDarker),
    // );
  }
}
