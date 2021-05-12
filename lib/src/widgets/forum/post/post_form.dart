import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

class PostForm extends StatefulWidget {
  PostForm(
    this.forum, {
    this.subcategories = const [],
    this.onSuccess,
    this.onCancel,
    this.onError,
  });
  final ApiForum forum;
  final Function onSuccess;
  final Function onCancel;
  final Function onError;
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
      borderRadius: const BorderRadius.all(
        const Radius.circular(10.0),
      ),
    ),
  );

  onImageIconTap() async {
    FocusScope.of(context).requestFocus(new FocusNode());

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
  }

  @override
  Widget build(BuildContext context) {
    ApiForum forum = widget.forum;

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
                                ? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
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
              child: Text('title'.tr),
            ),
            TextFormField(
              key: ValueKey(FirelampKeys.element.postTitleInput),
              controller: title,
              decoration: _inputDecoration,
            ),
            Padding(
              padding: EdgeInsets.only(top: Space.md, bottom: Space.xs),
              child: Text('content'.tr),
            ),
            TextFormField(
              key: ValueKey(FirelampKeys.element.postContentInput),
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
                          'cancel'.tr,
                          style: TextStyle(
                            color: Colors.red[300],
                          ),
                        ),
                        onPressed: () {
                          forum.postInEdit = null;
                          if (widget.onCancel != null) widget.onCancel();
                        },
                      ),
                    SizedBox(width: Space.xs),
                    TextButton(
                      key: ValueKey(FirelampKeys.button.postFormSubmit),
                      child: loading
                          ? Spinner()
                          : Text(
                              'submit'.tr,
                              style: TextStyle(color: Colors.green[300]),
                            ),
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
