import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/forum/comment/comment_content.dart';
import 'package:firelamp/widgets/forum/shared/display_files.dart';
import 'package:firelamp/widgets/itsuda/itsuda_confirm_dialog.dart';
import 'package:firelamp/widgets/popup_button.dart';
import 'package:firelamp/widgets/rounded_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/comment/comment_meta.dart';
import 'package:firelamp/widgets/forum/comment/comment_form.dart';

import 'package:firelamp/widgets/user/user_avatar.dart';

class CommentView extends StatefulWidget {
  const CommentView({
    Key key,
    this.comment,
    this.post,
    this.onError,
    @required this.forum,
    this.rerenderParent,
    this.index,
    @required this.onFileDelete,
  }) : super(key: key);

  final ApiComment comment;
  final ApiPost post;
  final ApiForum forum;
  final Function onError;
  final Function rerenderParent;
  final Function onFileDelete;
  final int index;

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  /// when user is done selecting from the popup menu.
  onPopupMenuItemSelected(selected) async {
    /// Edit
    if (selected == 'edit') {
      print('edit: $selected');
      setState(() {
        widget.comment.mode = CommentMode.edit;
      });
    }

    /// Delete
    if (selected == 'delete') {
      await showDialog(
        context: context,
        builder: (context) => ItsudaConfirmDialog(
          title: '글 삭제하기',
          content: Text(
            '이 글을 삭제하시겠습니까?',
            style: TextStyle(fontSize: 20),
          ),
          okButton: () async {
            try {
              await Api.instance.commentDelete(widget.comment, widget.post);
              widget.post.comments.removeWhere((c) => c.idx == widget.comment.idx);
              if (widget.rerenderParent != null) widget.rerenderParent();
              if (widget.forum.render != null) widget.forum.render();
              Get.back();
            } catch (e) {
              if (widget.onError != null) {
                widget.onError(e);
              }
            }
          },
        ),
      );

      // bool conf = await confirm(
      //   'confirm'.tr,
      //   'comment_confirm_delete_message'.tr,
      // );
      // if (conf == false) return;

      // try {
      //   await Api.instance.commentDelete(widget.comment, widget.post);
      //   widget.post.comments.removeWhere((c) => c.idx == widget.comment.idx);
      //   if (widget.rerenderParent != null) widget.rerenderParent();
      //   if (widget.forum.render != null) widget.forum.render();
      // } catch (e) {
      //   if (widget.onError != null) {
      //     widget.onError(e);
      //   }
      // }
    }
  }

  bool get canCancel =>
      widget.comment.mode == CommentMode.reply || widget.comment.mode == CommentMode.edit;

  @override
  Widget build(BuildContext context) {
    return widget.comment.isDeleted
        ? SizedBox.shrink()
        : RoundedBox(
            padding: EdgeInsets.all(Space.xsm),
            margin:
                EdgeInsets.only(top: Space.xsm, left: Space.sm * (widget.comment.depth.toInt - 1)),
            boxColor: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    widget.forum.commentAvatarBuilder == null
                        ? UserAvatar(widget.comment.user.photoUrl, size: 40)
                        : widget.forum.commentAvatarBuilder(widget.comment),
                    SizedBox(width: Space.sm),
                    CommentMeta(forum: widget.forum, comment: widget.comment),
                  ],
                ),
                if (widget.comment.mode == CommentMode.none ||
                    widget.comment.mode == CommentMode.reply) ...[
                  CommentContent(widget.comment),
                  DisplayFiles(postOrComment: widget.comment),
                  Divider(height: Space.sm, thickness: 1.3),
                  Row(children: [
                    IconButton(
                      icon: Icon(
                          widget.comment.mode == CommentMode.reply
                              ? Icons.close
                              : Icons.reply_rounded,
                          size: 20),
                      onPressed: () {
                        setState(() {
                          widget.comment.mode = widget.comment.mode == CommentMode.reply
                              ? CommentMode.none
                              : CommentMode.reply;
                        });
                      },
                    ),
                    if (widget.forum.commentButtonBuilder != null)
                      widget.forum.commentButtonBuilder(widget.post, widget.comment),
                    Spacer(),
                    if (widget.comment.isMine)
                      PopUpButton(
                        key: ValueKey(FirelampKeys.button.commentMore),
                        items: [
                          PopupMenuItem(
                              key: ValueKey(FirelampKeys.button.commentMoreEdit),
                              child: Row(children: [
                                Icon(Icons.edit, size: Space.sm, color: Colors.black),
                                SizedBox(width: Space.xs),
                                Text('edit'.tr),
                              ]),
                              value: 'edit'),
                          PopupMenuItem(
                              key: ValueKey(FirelampKeys.button.commentMoreDelete),
                              child: Row(children: [
                                Icon(Icons.delete, size: Space.sm, color: Colors.black),
                                SizedBox(width: Space.xs),
                                Text('delete'.tr)
                              ]),
                              value: 'delete')
                        ],
                        onSelected: onPopupMenuItemSelected,
                      )
                  ]),
                ],
                if (widget.comment.mode == CommentMode.reply)
                  CommentForm(
                    parent: widget.comment,
                    comment: ApiComment(),
                    post: widget.post,
                    forum: widget.forum,
                    onSuccess: widget.rerenderParent,
                    onError: widget.onError,
                    index: widget.index,
                    onFileDelete: widget.onFileDelete,
                  ),
                if (widget.comment.mode == CommentMode.edit) ...[
                  SizedBox(height: Space.sm),
                  CommentForm(
                    comment: widget.comment,
                    post: widget.post,
                    forum: widget.forum,
                    onSuccess: widget.rerenderParent,
                    onError: widget.onError,
                    index: widget.index,
                    onCancel: () => setState(() => widget.comment.mode = CommentMode.none),
                    commentFormKeyFix: 'edit',
                    onFileDelete: widget.onFileDelete,
                  ),
                ],
              ],
            ),
          );
  }
}
