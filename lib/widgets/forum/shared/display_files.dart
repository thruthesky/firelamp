import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/app_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../app_video_viewer.dart';

class DisplayFiles extends StatefulWidget {
  DisplayFiles({
    Key key,
    this.postOrComment,
    this.displayedImageOrMovie = 4,
  }) : super(key: key);

  final dynamic postOrComment;
  final int displayedImageOrMovie;

  @override
  _DisplayFilesState createState() => _DisplayFilesState();
}

class _DisplayFilesState extends State<DisplayFiles> {
  VideoPlayerController videoPlayerController;

  initializePlayer(String url) async {
    videoPlayerController = VideoPlayerController.network(url);
    await Future.wait([
      videoPlayerController.initialize(),
    ]);
  }

  int get moreFile => widget.postOrComment.files.length - widget.displayedImageOrMovie;

  onImageTap(String idx) {
    final i = widget.postOrComment.files.indexWhere((file) => file.idx == idx);
    if (isImageUrl(widget.postOrComment.files[i].url)) {
      Get.dialog(AppPhotoViewer(widget.postOrComment.files, initialIndex: i));
    }
  }

  Widget _fileBuilder(file, {bool withMoreImageOverlay = false}) {
    Widget image;
    if (isImageUrl(file.url)) {
      image = CachedImage(file.url);
      print('isImageUrl: $isImageUrl(file.url');
    } else if (isMovie(file.url)) {
      initializePlayer(file.url);
      print('videoPlayerController.value ${videoPlayerController.value}');
    }

//  Stack(alignment: AlignmentDirectional.center, children: [
//                 AspectRatio(
//                   aspectRatio: videoPlayerController.value.aspectRatio,
//                   child: ClipRRect(
//                       borderRadius: BorderRadius.circular(Space.xsm),
//                       child: VideoPlayer(videoPlayerController)),
//                 ),
//                 GestureDetector(
//                     behavior: HitTestBehavior.opaque,
//                     child: Icon(
//                       Icons.play_circle_outline,
//                       color: Colors.white,
//                       size: Space.xxl,
//                     ),
//                     onTap: () {
//                       Get.dialog(AppVideoViewer([file]));
//                     }),
//               ]),

    return ClipRRect(
      child: image != null
          ? GestureDetector(
              child: moreFile > 0
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        if (moreFile > 0 && withMoreImageOverlay)
                          Container(
                            color: Color.fromARGB(100, 0, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '+ $moreFile',
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
            )
          : Container(
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
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Widget _gridBuilder({bool hideFirstImage = false}) {
    List<ApiFile> _files = hideFirstImage
        ? widget.postOrComment.files.getRange(1, widget.postOrComment.files.length).toList()
        : widget.postOrComment.files;

    return widget.postOrComment.files.length > 3
        ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            crossAxisCount: 4,
            itemCount: widget.displayedImageOrMovie,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) => Container(
                  child: (index + 1) > 4
                      ? SizedBox.shrink()
                      : _fileBuilder(
                          _files[index],
                          withMoreImageOverlay: (index + 1) == (widget.displayedImageOrMovie - 1),
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
            crossAxisCount: widget.postOrComment.files.length <= 3 ? 2 : 3,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 4.0,
            children: [
              for (ApiFile file in _files) _fileBuilder(file),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    int filesLength = widget.postOrComment.files.length;

    if (filesLength == 0) return SizedBox.shrink();
    if (filesLength == 1) return _fileBuilder(widget.postOrComment.files.first);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Space.xsm),
          if (filesLength == 1) _fileBuilder(widget.postOrComment.files.first),
          if (filesLength == 3) ...[
            Container(
              height: 200,
              width: double.maxFinite,
              child: _fileBuilder(widget.postOrComment.files.first),
            ),
            SizedBox(height: 4.0),
          ],
          if (filesLength > 1) _gridBuilder(hideFirstImage: filesLength == 3),
        ],
      ),
    );
  }
}
