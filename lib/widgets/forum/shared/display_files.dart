import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/app_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class DisplayFiles extends StatelessWidget {
  const DisplayFiles({
    Key key,
    this.postOrComment,
    this.displayedImage = 4,
  }) : super(key: key);

  final dynamic postOrComment;
  final int displayedImage;

  int get moreImage => postOrComment.files.length - displayedImage;

  onImageTap(int idx) {
    final i = postOrComment.files.indexWhere((file) => file.idx == idx);
    Get.dialog(AppPhotoViewer(postOrComment.files, initialIndex: i));
  }

  Widget _imageBuilder(file, {bool withMoreImageOverlay = false}) {
    Widget image = CachedImage(file.url);

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

  Widget _gridBuilder({bool hideFirstImage = false}) {
    List<ApiFile> _files = hideFirstImage
        ? postOrComment.files.getRange(1, postOrComment.files.length).toList()
        : postOrComment.files;

    return postOrComment.files.length > 3
        ? StaggeredGridView.countBuilder(

            shrinkWrap: true,
            crossAxisCount: 4,
            itemCount: displayedImage,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) => Container(
              child: (index + 1) > 4
                  ? SizedBox.shrink()
                  : _imageBuilder(
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
            primary: false
          )
        : GridView.count(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: postOrComment.files.length <= 3 ? 2 : 3,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 8.0,
            children: [
              for (ApiFile file in _files) _imageBuilder(file),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    int filesLength = postOrComment.files.length;

    if (filesLength == 0) return SizedBox.shrink();
    // if (filesLength == 1) return _imageBuilder(postOrComment.files.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Space.xsm),
        if (filesLength == 1) _imageBuilder(postOrComment.files.first),
        if (filesLength == 3) ...[
          Container(
            height: 200,
            width: double.maxFinite,
            child: _imageBuilder(postOrComment.files.first),
          ),
          SizedBox(height: Space.xsm),
        ],
        if (filesLength > 1) _gridBuilder(hideFirstImage: filesLength == 3),
      ],
    );
  }
}
