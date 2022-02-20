import 'package:firelamp/widgets/circle_icon.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Basic(sample) widget for creating a post
///
/// ```dart
/// ForumBasicPostEdit(
///   category: 'qna',
///   onCancel: () {
///     print('cancel:');
///   },
///   onSuccess: (post) {
///     print('success: $post');
///   },
///   onError: (e) {
///     print('error: $e');
///     app.error(e);
///   },
/// ),
/// ```dart
///
class ForumBasicPostEdit extends StatefulWidget {
  ForumBasicPostEdit({
    @required this.category,
    @required this.onSuccess,
    @required this.onCancel,
    @required this.onError,
  });
  final String category;
  final Function onSuccess;
  final Function onCancel;
  final Function onError;

  @override
  _ForumBasicPostEditState createState() => _ForumBasicPostEditState();
}

class _ForumBasicPostEditState extends State<ForumBasicPostEdit> {
  ApiPost post;

  @override
  void initState() {
    super.initState();
    post = ApiPost(categoryId: widget.category);
  }

  bool get canSubmit {
    if (post.title == '') return false;
    if (post.content == '' && post.files.length == 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        TextField(
          onChanged: (text) => setState(() => post.title = text),
          decoration: InputDecoration(labelText: '제목을 입력하세요.'),
        ),
        TextField(
          onChanged: (text) => setState(() => post.content = text),
          decoration: InputDecoration(labelText: '내용을 입력하세요.'),
          maxLines: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () async {
                final ImageSource source = await showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                          title: Text('카메라로 사진을 찍거나 갤러리에서 사진을 가져오세요.'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('카메라로 사진 찍기'),
                                onTap: () => Get.back(result: ImageSource.camera),
                              ),
                              ListTile(
                                leading: Icon(Icons.photo),
                                title: Text('갤러리에서 사진 가져오기'),
                                onTap: () => Get.back(result: ImageSource.gallery),
                              ),
                              ListTile(
                                leading: Icon(Icons.cancel),
                                title: Text('취소'),
                                onTap: () => Get.back(result: null),
                              ),
                            ],
                          ));
                    });
                if (source == null) return;
                try {
                  final res = await Api.instance.takeUploadFile(
                      source: source,
                      onProgress: (p) {
                        // print('p: $p');
                      });
                  post.files.add(res);
                  setState(() {});
                  // print('success: $res');
                } catch (e) {
                  widget.onError(e);
                }
              },
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: canSubmit
                      ? () async {
                          try {
                            // print('req: $post');
                            ApiPost re = await Api.instance.postEdit(post: post);
                            re.display = false;
                            widget.onSuccess(re);
                          } catch (e) {
                            widget.onError(e);
                          }
                        }
                      : null,
                  child: Text('전송'),
                )
              ],
            )
          ],
        ),
        if (post.files.length > 0)
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                for (final file in post.files)
                  Stack(
                    children: [
                      Image.network(
                        file.thumbnailUrl,
                        width: 100,
                        height: 100,
                      ),
                      CircleIcon(
                          icon: Icon(Icons.delete),
                          backgroundColor: Colors.grey[800],
                          onPressed: () async {
                            // print('delete: ${file.id}');
                            try {
                              await Api.instance.deleteFile(file.idx, postOrComment: post);
                              // print('delete: success');
                              setState(() {});
                            } catch (e) {
                              widget.onError(e);
                            }
                          }),
                    ],
                  ),
              ],
            ),
          ),
      ],
    ));
  }
}
