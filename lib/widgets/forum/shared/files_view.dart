import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/app_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class FilesView extends StatelessWidget {
  const FilesView({
    Key key,
    this.postOrComment,
    this.isStaggered = false,
  }) : super(key: key);

  final dynamic postOrComment;
  final bool isStaggered;

  onImageTap(int idx) {
    final i = postOrComment.files.indexWhere((file) => file.idx == idx);
    Get.dialog(AppPhotoViewer(postOrComment.files, initialIndex: i));
  }

  Widget _imageBuilder(file) {
    return ClipRRect(
      child: GestureDetector(
        child: CachedImage(file.url),
        onTap: () => onImageTap(file.idx),
      ),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Widget _gridBuilder({bool hideFirstImage = false}) {
    List<ApiFile> _files = hideFirstImage
        ? postOrComment.files.getRange(1, postOrComment.files.length).toList()
        : postOrComment.files;

    return isStaggered && postOrComment.files.length != 3
        ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            crossAxisCount: 4,
            itemCount: _files.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) => Container(
              color: Colors.green,
              child: _imageBuilder(_files[index]),
            ),
            staggeredTileBuilder: (int index) => StaggeredTile.count(
              2,
              index.isEven ? 2 : 1,
            ),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          )
        : GridView.count(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: postOrComment.files.length == 3 ? 2 : 3,
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
    if (filesLength == 1) return _imageBuilder(postOrComment.files.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (!isStaggered) ...[
        SizedBox(height: Space.xsm),
        Text(
          'Attached files',
          style: TextStyle(color: Colors.grey, fontSize: Space.xsm),
        ),
        Divider(),
        // ],
        if (filesLength == 3) ...[
          _imageBuilder(postOrComment.files.first),
          SizedBox(height: Space.xsm),
        ],
        _gridBuilder(hideFirstImage: filesLength == 3),
      ],
    );
  }
}
