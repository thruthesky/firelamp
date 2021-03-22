import 'package:firelamp/widgets/image.cache.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';
import 'package:get/get.dart';

import 'package:firelamp/widgets/defines.dart';

class DisplayUploadedFilesAndDeleteButtons extends StatefulWidget {
  const DisplayUploadedFilesAndDeleteButtons(
      {Key key, this.postOrComment, this.onError})
      : super(key: key);

  final postOrComment;
  final Function onError;

  @override
  _DisplayUploadedFilesAndDeleteButtonsState createState() =>
      _DisplayUploadedFilesAndDeleteButtonsState();
}

class _DisplayUploadedFilesAndDeleteButtonsState
    extends State<DisplayUploadedFilesAndDeleteButtons> {
  @override
  Widget build(BuildContext context) {
    if (widget.postOrComment == null || widget.postOrComment.files.length == 0)
      return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Space.xs),
        Text('Uploaded files'),
        Divider(),
        GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: [
            for (ApiFile file in widget.postOrComment.files)
              Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    child: CachedImage(file.url),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  Positioned(
                    width: 50,
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0x77FFFFFF),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.grey[700],
                        ),
                      ),
                      onPressed: () async {
                        final re = await confirm(
                          'confirm'.tr,
                          'photo_confirm_delete_message'.tr,
                        );
                        // print('delete: $re');
                        if (re) {
                          try {
                            await Api.instance.deleteFile(
                              file.idx,
                              postOrComment: widget.postOrComment,
                            );
                            setState(() => null);
                          } catch (e) {
                            if (widget.onError != null) {
                              widget.onError(e);
                            }
                          }
                        }
                      },
                    ),
                  )
                ],
              )
          ],
        ),
      ],
    );
  }
}
