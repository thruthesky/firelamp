import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/functions.dart';
import 'package:firelamp/widgets/itsuda/itsuda_confirm_dialog.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/shared/display_uploaded_files_and_delete_buttons.dart';

class PostForm extends StatefulWidget {
  PostForm(
    this.forum, {
    this.subcategories = const [],
    this.onSuccess,
    this.onCancel,
    this.onError,
    this.togglePostForm,
    @required this.onFileDelete,
  });
  final ApiForum forum;
  final Function onSuccess;
  final Function onCancel;
  final Function onError;
  final Function onFileDelete;
  final Function togglePostForm;
  final List<String> subcategories;

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
      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
      borderSide: const BorderSide(color: Color(0xFFB8860B), width: 2),
    ),
  );

  onImageIconTap() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    try {
      // final file = await imageUpload(
      //   quality: 95,
      //   onProgress: (p) => setState(
      //     () => percentage = p,
      //   ),
      // );
      final file = await fileUpload(
        quality: 95,
        onProgress: (p) => setState(
          () => percentage = p,
        ),
      );
      percentage = 0;
      post.files.add(file);
      setState(() => null);
    } catch (e) {
      if (e == ERROR_IMAGE_NOT_SELECTED || e == ERROR_VIDEO_NOT_SELECTED) {
      } else {
        onError(e);
      }
    }
  }

  onFormSubmit() async {
    print('onFormSubmit()');
    if (loading) return;
    setState(() => loading = true);

    if (Api.instance.notLoggedIn) return onError("login_first".tr);
    try {
      final editedPost = await Api.instance.postEdit(
        idx: post.idx,
        categoryId: widget.forum.categoryId,
        subcategory: widget.forum.subcategory,
        title: title.text,
        content: content.text,
        files: post.files,
      );
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
    SchedulerBinding.instance.addPostFrameCallback((_) => widget.togglePostForm(true));
    print('PostForm: ${widget.forum.categoryId}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApiForum forum = widget.forum;
    // if (forum.postInEdit.subcategory != '' || forum.postInEdit.subcategory != null)
    //   forum.subcategory = forum.postInEdit.subcategory;
    if (forum.postInEdit == null) return SizedBox.shrink();
    return SingleChildScrollView(
      child: Container(
        key: ValueKey(FirelampKeys.element.postEditForm),
        padding: EdgeInsets.all(Space.sm),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.subcategories.isNotEmpty)
              Row(children: [
                Text('subcategory'.tr),
                SizedBox(width: Space.md),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: forum.subcategory,
                    hint: Text('uncategorized'.tr),
                    onChanged: (cat) {
                      if (cat == forum.subcategory) return;
                      forum.subcategory = cat;
                      setState(() {});
                    },
                    items: [
                      DropdownMenuItem(child: Text('uncategorized'.tr), value: null),
                      for (final String cat in widget.subcategories)
                        DropdownMenuItem(
                          child: Text(
                            '$cat',
                            style: cat == forum.subcategory
                                ? TextStyle(fontWeight: FontWeight.bold)
                                : null,
                          ),
                          value: cat,
                        ),
                    ],
                  ),
                ),
              ]),
            Padding(
              padding: EdgeInsets.only(top: Space.xs, bottom: Space.xs),
            ),
            TextFormField(
              cursorColor: Color(0xFFB8860B),
              key: ValueKey(FirelampKeys.element.postTitleInput),
              controller: title,
              decoration: _inputDecoration,
            ),
            Padding(
              padding: EdgeInsets.only(top: Space.md, bottom: Space.xs),
              child: Text('content'.tr),
            ),
            TextFormField(
              cursorColor: Color(0xFFB8860B),
              key: ValueKey(FirelampKeys.element.postContentInput),
              controller: content,
              minLines: 5,
              maxLines: 15,
              decoration: _inputDecoration,
            ),
            DisplayUploadedFilesAndDeleteButtons(
              postOrComment: forum.postInEdit,
              onFileDelete: widget.onFileDelete,
            ),
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
                      child: LinearProgressIndicator(
                        value: percentage,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFdd00)),
                      ),
                    ),
                  ),

                /// Submit button
                Row(
                  children: [
                    if (!loading)
                      TextButton(
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ItsudaConfirmDialog(
                                title: '글쓰기 취소',
                                content: Text(
                                  '글쓰기에서 나가겠습니까?',
                                  style: Theme.of(Get.context).textTheme.bodyText1,
                                ),
                                okButton: () {
                                  forum.postInEdit = null;
                                  if (widget.onCancel != null) widget.onCancel();
                                  widget.togglePostForm(false);
                                  Get.back();
                                },
                              ),
                            );
                          }),
                    TextButton(
                        key: ValueKey(FirelampKeys.button.postFormSubmit),
                        child: loading
                            ? Spinner()
                            : Text(
                                'submit'.tr,
                                style: TextStyle(color: Colors.black),
                              ),
                        onPressed: () {
                          onFormSubmit();
                          widget.togglePostForm(false);
                        }),
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
