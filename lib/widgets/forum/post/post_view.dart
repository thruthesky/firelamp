import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/post/post_title.dart';
import 'package:firelamp/widgets/forum/post/post_content.dart';
import 'package:firelamp/widgets/forum/shared/display_files.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/comment/comment_form.dart';
import 'package:firelamp/widgets/forum/comment/comment_list.dart';

class PostView extends StatefulWidget {
  const PostView({
    Key key,
    this.post,
    this.forum,
    this.avatarBuilder,
    this.nameBuilder,
    this.open = false,
    this.onError,
    @required this.onFileDelete,
  }) : super(key: key);

  final ApiForum forum;
  final ApiPost post;

  // final List<Widget> actions;
  final Function onError;
  final bool open;

  /// Move avatarBuilder to [ApiForum]. This is a common widget for post and comment.
  final Function avatarBuilder;

  /// Move nameBuilder to [ApiForum]. This is a common widget for post and comment.
  final Function nameBuilder;

  final Function onFileDelete;

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  bool get showContent {
    if (widget.open) return true;
    if (widget.post.display) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            widget.avatarBuilder == null
                ? UserAvatar(widget.post.user.photoUrl)
                : widget.avatarBuilder(widget.post),
            SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.nameBuilder == null
                      ? name
                      : widget.nameBuilder(widget.post),
                  SizedBox(height: Space.xs),
                  PostMeta(widget.post, widget.forum),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: Space.sm),
        PostTitle(widget.post, widget.forum, buildFor: 'view'),
        PostContent(widget.post, widget.forum, buildFor: 'view'),
        DisplayFiles(postOrComment: widget.post),
        Divider(height: Space.xs),
        if (widget.forum.postBottomBuilder != null)
          widget.forum.postBottomBuilder(widget.post),
        if (widget.forum.postButtonBuilder != null)
          widget.forum.postButtonBuilder(widget.post),
        CommentForm(
          post: widget.post,
          forum: widget.forum,
          comment: ApiComment(),
          onError: widget.onError,
          onSuccess: () => setState(() => null),
          onFileDelete: widget.onFileDelete,
        ),
        CommentList(
          post: widget.post,
          forum: widget.forum,
          onError: widget.onError,
          rerenderParent: () => setState(() => null),
          onFileDelete: widget.onFileDelete,
        ),
      ],
    );
  }

  Widget get name {
    return Text(
      '${widget.post.user.name.isNotEmpty ? widget.post.user.name : 'No name'}',
      style: TextStyle(fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
