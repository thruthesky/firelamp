import 'package:firelamp/widgets/functions.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/shared/display_uploaded_files_and_delete_buttons.dart';

class PostForm extends StatefulWidget {
  PostForm(this.forum, {this.onSuccess, this.onError});

  final ApiForum forum;
  final Function onSuccess;
  final Function onError;

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final title = TextEditingController();
  final content = TextEditingController();
  double percentage = 0;
  bool loading = false;
  ApiPost post;
  List<String> categories;
  String category;

  InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    contentPadding: EdgeInsets.all(Space.sm),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(10.0),
      ),
    ),
  );

  onImageIconTap() async {
    try {
      final file = await imageUpload(
        quality: 95,
        onProgress: (p) => setState(
          () => percentage = p,
        ),
      );
      percentage = 0;
      post.files.add(file);
      setState(() => null);
    } catch (e) {
      if (e == ERROR_IMAGE_NOT_SELECTED) {
      } else {
        onError(e);
      }
    }
  }

  onFormSubmit() async {
    if (loading) return;
    setState(() => loading = true);

    if (Api.instance.notLoggedIn) return onError("Login First");
    try {
      final editedPost = await Api.instance.postEdit(
        idx: post.idx,
        categoryId: widget.forum.categoryId,
        title: title.text,
        content: content.text,
        files: post.files,
      );
      if (widget.forum.postView != 'slide') {
        editedPost.display = true;
      }
      widget.forum.insertOrUpdatePost(editedPost);
      setState(() => loading = false);
      if (widget.onSuccess != null) widget.onSuccess(editedPost);
    } catch (e) {
      setState(() => loading = false);
      onError(e);
    }
  }

  onError(dynamic e) {
    if (widget.onError != null) widget.onError(e);
  }

  @override
  void initState() {
    super.initState();
    post = widget.forum.postInEdit;
    title.text = post.title;
    content.text = post.content;
  }

  @override
  Widget build(BuildContext context) {
    ApiForum forum = widget.forum;

    if (forum.postInEdit == null) return SizedBox.shrink();
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(Space.sm),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Space.xs, bottom: Space.xs),
              child: Text('title'.tr),
            ),
            TextFormField(
              controller: title,
              decoration: _inputDecoration,
            ),
            Padding(
              padding: EdgeInsets.only(top: Space.md, bottom: Space.xs),
              child: Text('content'.tr),
            ),
            TextFormField(
              controller: content,
              minLines: 5,
              maxLines: 15,
              decoration: _inputDecoration,
            ),
            DisplayUploadedFilesAndDeleteButtons(postOrComment: forum.postInEdit),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Upload Button
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: onImageIconTap,
                ),
                if (percentage > 0)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: Space.sm),
                      child: LinearProgressIndicator(value: percentage),
                    ),
                  ),

                /// Submit button
                Row(
                  children: [
                    if (!loading)
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red[300],
                          ),
                        ),
                        onPressed: () {
                          forum.postInEdit = null;
                          forum..render();
                        },
                      ),
                    SizedBox(width: Space.xs),
                    TextButton(
                      child: loading
                          ? Spinner()
                          : Text('Submit', style: TextStyle(color: Colors.green[300])),
                      onPressed: onFormSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
