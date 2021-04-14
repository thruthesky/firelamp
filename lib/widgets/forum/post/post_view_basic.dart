import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/shared/display_files.dart';
import 'package:firelamp/widgets/forum/shared/vote_buttons.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/comment/comment_form.dart';
import 'package:firelamp/widgets/forum/comment/comment_list.dart';

class PostViewBasic extends StatefulWidget {
  const PostViewBasic({
    Key key,
    this.post,
    this.forum,
    this.actions = const [],
    this.open = false,
    this.onError,
    this.avatarBuilder,
    this.nameBuilder,
  }) : super(key: key);

  final ApiForum forum;
  final ApiPost post;

  final List<Widget> actions;
  final Function onError;
  final bool open;

  final Function avatarBuilder;
  final Function nameBuilder;

  @override
  _PostViewBasicState createState() => _PostViewBasicState();
}

class _PostViewBasicState extends State<PostViewBasic> {
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
        Divider(height: Space.xs, thickness: 1.3),
        Row(children: [
          VoteButtons(
            widget.post,
            widget.forum,
            onSuccess: () => setState(() => null),
            onError: widget.onError,
          ),
          ...widget.actions,
        ]),
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
