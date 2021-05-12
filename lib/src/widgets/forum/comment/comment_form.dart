import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentForm extends StatefulWidget {
  const CommentForm({
    Key key,
    @required this.post,
    this.parent,
    this.comment,
    @required this.forum,
    this.onError,
    this.onSuccess,
    this.onCancel,
    this.index,
    this.commentFormKeyFix = '',
  }) : super(key: key);

  /// post of the comment
  final ApiPost post;
  final ApiComment parent;
  final ApiComment comment;
  final ApiForum forum;
  final Function onError;
  final Function onSuccess;
  final Function onCancel;
  final int index;
  final String commentFormKeyFix;

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final content = TextEditingController();

  /// [comment] to create or update
  ///
  /// Attention, the reason why it has a copy in state class is because
  /// when the app does hot reload(in development mode), the state disappears
  /// (like when file is uploaded and it disappears on hot reload).
  ApiComment comment;

  bool loading = false;

  bool get canSubmit => (content.text != '' || comment.files.isNotEmpty) && !loading;
  double percentage = 0;

  // file upload
  onImageIconPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    try {
      final file = await imageUpload(
        quality: 95,
        onProgress: (p) => setState(() => percentage = p),
      );
      percentage = 0;
      comment.files.add(file);
      setState(() => null);
    } catch (e) {
      if (e == ERROR_IMAGE_NOT_SELECTED) {
      } else {
        onError(e);
      }
    }
  }

  // form submit
  onFormSubmit() async {
    if (Api.instance.notLoggedIn) return onError("login_first".tr);

    if (widget.forum.commentCanEdit != null) {
      if (widget.forum.commentCanEdit() == false) {
        return;
      }
    }

    if (loading) return;
    setState(() => loading = true);
    FocusScope.of(context).requestFocus(FocusNode());

    try {
      final editedComment = await Api.instance.commentEdit(
        idx: comment?.idx,
        content: content.text,
        rootIdx: widget.post.idx,
        parentIdx: widget.parent != null ? widget.parent.idx : widget.post.idx,
        comment: comment,
        files: comment.files,
      );

      widget.post.insertOrUpdateComment(editedComment);
      content.text = '';
      comment.files = [];
      loading = false;
      if (widget.parent != null) widget.parent.mode = CommentMode.none;
      if (widget.comment != null) comment.mode = CommentMode.none;
      setState(() => null);
      if (widget.forum.render != null) widget.forum.render();
      if (widget.onSuccess != null) widget.onSuccess();
    } catch (e) {
      setState(() => loading = false);
      onError(e);
    }
  }

  onError(dynamic e) {
    if (widget.onError != null) {
      widget.onError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
    content.text = comment.content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.comment?.idx != null)
                IconButton(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(maxWidth: Space.md),
                  icon: Icon(Icons.close),
                  onPressed: widget.onCancel,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: Space.xsm),
                ),
              IconButton(
                alignment: Alignment.center,
                icon: Icon(Icons.camera_alt, color: Colors.black),
                onPressed: onImageIconPressed,
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey('${FirelampKeys.element.commentFormTextField}${widget.commentFormKeyFix}'),
                  controller: content,
                  onChanged: (v) => setState(() => null),
                  minLines: 1,
                  maxLines: 10,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(Space.sm),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
              if (!canSubmit) SizedBox(width: Space.sm),
              if (loading)
                Padding(
                  padding: EdgeInsets.all(Space.sm),
                  child: Spinner(centered: false, size: 18),
                ),
              if (canSubmit)
                IconButton(
                  key: ValueKey(FirelampKeys.button.commentFormSubmit),
                  alignment: Alignment.center,
                  icon: Icon(Icons.send_rounded),
                  onPressed: onFormSubmit,
                ),
              if (canSubmit) SizedBox(width: Space.xsm),
            ],
          ),
          DisplayUploadedFilesAndDeleteButtons(postOrComment: comment),
        ],
      ),
    );
  }
}
