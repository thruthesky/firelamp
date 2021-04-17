import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
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
    // this.actions = const [],
    this.avatarBuilder,
    this.nameBuilder,
    this.open = false,
    this.onError,
    this.bottomBuilder,
  }) : super(key: key);

  final ApiForum forum;
  final ApiPost post;

  // final List<Widget> actions;
  final Function onError;
  final bool open;

  final Function avatarBuilder;
  final Function nameBuilder;
  final Function bottomBuilder;

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
                  widget.nameBuilder == null ? name : widget.nameBuilder(widget.post),
                  SizedBox(height: Space.xs),
                  PostMeta(widget.post, widget.forum),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: Space.sm),
        Text(
          '${widget.post.title}',
          key: ValueKey(FirelampKeys.element.postTitle),
          style: stylePostTitle,
        ),
        SizedBox(height: Space.sm),
        Text(
          '${widget.post.content}',
          key: ValueKey(FirelampKeys.element.postContent),
          style: TextStyle(fontSize: Space.sm, wordSpacing: 2),
        ),
        DisplayFiles(postOrComment: widget.post),
        SizedBox(height: Space.xs),
        Divider(height: Space.xs),
        if (widget.bottomBuilder != null) widget.bottomBuilder(),
        if (widget.forum.postButtonBuilder != null) widget.forum.postButtonBuilder(widget.post),
        CommentForm(
          post: widget.post,
          forum: widget.forum,
          comment: ApiComment(),
          onError: widget.onError,
          onSuccess: () => setState(() {
            print('onSuccess!');
          }),
        ),
        CommentList(
          post: widget.post,
          forum: widget.forum,
          onError: widget.onError,
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
