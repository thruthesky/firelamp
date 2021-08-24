import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/app_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../app_video_viewer.dart';

// ignore: must_be_immutable
class DisplayFiles extends StatelessWidget {
  DisplayFiles({
    Key key,
    this.postOrComment,
    this.displayedImage = 4,
  }) : super(key: key);

  final dynamic postOrComment;
  final int displayedImage;

  VideoPlayerController videoPlayerController;
  List<ApiFile> imagefiles = [];
  List<ApiFile> videoFiles = [];

  initializePlayer(String url) async {
    videoPlayerController = VideoPlayerController.network(url);
    await Future.wait([
      videoPlayerController.initialize(),
    ]);
  }

  int get moreImage => imagefiles.length - displayedImage;

  onImageTap(String idx) {
    final i = imagefiles.indexWhere((file) => file.idx == idx);
    Get.dialog(AppPhotoViewer(imagefiles, initialIndex: i));
  }

  Widget _fileBuilder(ApiFile file, {bool withMoreImageOverlay = false}) {
    Widget image = CachedImage(file.url);
    print('_fileBuilder moreImage: $moreImage');

    return ClipRRect(
      child: GestureDetector(
        child: moreImage > 0
            ? Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  if (moreImage > 0 && withMoreImageOverlay)
                    Container(
                      color: Color.fromARGB(100, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+ $moreImage',
                            style: TextStyle(color: Colors.white, fontSize: Space.md),
                          ),
                          SizedBox(width: Space.xxs),
                          Icon(Icons.image_outlined, size: Space.lg, color: Colors.white)
                        ],
                      ),
                    ),
                ],
              )
            : image,
        onTap: () => onImageTap(file.idx),
      ),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Widget videoBuilder(ApiFile file) {
    initializePlayer(file.url);
    return Column(
      children: [
        Container(
          child: AspectRatio(
            aspectRatio: videoPlayerController.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(Space.xsm),
                        child: VideoPlayer(videoPlayerController)),
                  ),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: Space.xxl,
                      ),
                      onTap: () {
                        Get.dialog(AppVideoViewer([file]));
                      }),
                ]),
              ],
            ),
          ),
        ),
        SizedBox(
          height: Space.xsm,
        ),
      ],
    );
  }

  Widget _gridBuilder(List<ApiFile> files, {bool hideFirstImage = false}) {
    List<ApiFile> _files = hideFirstImage ? files.getRange(1, files.length).toList() : files;

    return files.length > 3
        ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            crossAxisCount: 4,
            itemCount: displayedImage,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) => Container(
                  child: (index + 1) > 4
                      ? SizedBox.shrink()
                      : _fileBuilder(
                          _files[index],
                          withMoreImageOverlay: (index + 1) == (displayedImage - 1),
                        ),
                ),
            staggeredTileBuilder: (int index) => StaggeredTile.count(
                  2,
                  index.isEven ? 2 : 1,
                ),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            primary: false)
        : GridView.count(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: files.length <= 3 ? 2 : 3,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 4.0,
            children: [
              for (ApiFile file in _files) _fileBuilder(file),
            ],
          );
  }

  imageBuilder(List<ApiFile> files) {
    print('imageBuilder: ${files.length}');
    int filesLength = files.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Space.xsm),
        if (filesLength == 0) SizedBox.shrink(),
        if (files.length == 1) _fileBuilder(files.first),
        if (filesLength == 3) ...[
          Column(
            children: [
              Container(
                height: 200,
                width: double.maxFinite,
                child: _fileBuilder(files.first),
              ),
            ],
          ),
          SizedBox(height: 4.0),
        ],
        if (filesLength > 1) _gridBuilder(files, hideFirstImage: filesLength == 3),
      ],
    );
  }

  placeFile(List<ApiFile> files) {
    for (final file in files) {
      if (isImageUrl(file.url)) {
        imagefiles.add(file);
      } else {
        videoFiles.add(file);
      }
    }

    print('videoFileslength: ${videoFiles.length}');
    print('imagefileslength: ${imagefiles.length}');

    return Column(
      children: [
        if (videoFiles.isNotEmpty)
          for (final videoFile in videoFiles) videoBuilder(videoFile),
        if (imagefiles.isNotEmpty) imageBuilder(imagefiles)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // int filesLength = widget.postOrComment.files.length;

    // if (filesLength == 0) return SizedBox.shrink();
    // if (filesLength == 1) return _fileBuilder(widget.postOrComment.files.first);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: placeFile(postOrComment.files),
    );
  }
}

// class DisplayFiles extends StatefulWidget {
// class DisplayFiles extends StatelessWidget {
//   const DisplayFiles({
//     Key key,
//     this.postOrComment,
//     this.displayedImage = 4,
//   }) : super(key: key);

//   final dynamic postOrComment;
//   final int displayedImage;

//   int get moreImage => postOrComment.files.length - displayedImage;

//   onImageTap(String idx) {
//     final i = postOrComment.files.indexWhere((file) => file.idx == idx);
//     Get.dialog(AppPhotoViewer(postOrComment.files, initialIndex: i));
//   }

//   Widget _imageBuilder(file, {bool withMoreImageOverlay = false}) {
//     Widget image = CachedImage(file.url);

//     return ClipRRect(
//       child: GestureDetector(
//         child: moreImage > 0
//             ? Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   image,
//                   if (moreImage > 0 && withMoreImageOverlay)
//                     Container(
//                       color: Color.fromARGB(100, 0, 0, 0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '+ $moreImage',
//                             style: TextStyle(color: Colors.white, fontSize: Space.md),
//                           ),
//                           SizedBox(width: Space.xxs),
//                           Icon(Icons.image_outlined, size: Space.lg, color: Colors.white)
//                         ],
//                       ),
//                     ),
//                 ],
//               )
//             : image,
//         onTap: () => onImageTap(file.idx),
//       ),
//       borderRadius: BorderRadius.circular(5.0),
//     );
//   }

//   Widget _gridBuilder({bool hideFirstImage = false}) {
//     List<ApiFile> _files = hideFirstImage
//         ? postOrComment.files.getRange(1, postOrComment.files.length).toList()
//         : postOrComment.files;

//     return postOrComment.files.length > 3
//         ? StaggeredGridView.countBuilder(
//             shrinkWrap: true,
//             padding: EdgeInsets.all(0),
//             crossAxisCount: 4,
//             itemCount: displayedImage,
//             physics: NeverScrollableScrollPhysics(),
//             itemBuilder: (BuildContext context, int index) => Container(
//                   child: (index + 1) > 4
//                       ? SizedBox.shrink()
//                       : _imageBuilder(
//                           _files[index],
//                           withMoreImageOverlay: (index + 1) == (displayedImage - 1),
//                         ),
//                 ),
//             staggeredTileBuilder: (int index) => StaggeredTile.count(
//                   2,
//                   index.isEven ? 2 : 1,
//                 ),
//             mainAxisSpacing: 4.0,
//             crossAxisSpacing: 4.0,
//             primary: false)
//         : GridView.count(
//             padding: EdgeInsets.all(0),
//             physics: NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             crossAxisCount: postOrComment.files.length <= 3 ? 2 : 3,
//             mainAxisSpacing: 5.0,
//             crossAxisSpacing: 4.0,
//             children: [
//               for (ApiFile file in _files) _imageBuilder(file),
//             ],
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     int filesLength = postOrComment.files.length;

//     if (filesLength == 0) return SizedBox.shrink();
//     // if (filesLength == 1) return _imageBuilder(postOrComment.files.first);

//     return Padding(
//       padding: const EdgeInsets.only(bottom: Space.sm),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: Space.xsm),
//           if (filesLength == 1) _imageBuilder(postOrComment.files.first),
//           if (filesLength == 3) ...[
//             Container(
//               height: 200,
//               width: double.maxFinite,
//               child: _imageBuilder(postOrComment.files.first),
//             ),
//             SizedBox(height: 4.0),
//           ],
//           if (filesLength > 1) _gridBuilder(hideFirstImage: filesLength == 3),
//         ],
//       ),
//     );
//   }
// }
