import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/cupertino.dart';

class PostTitle extends StatelessWidget {
  PostTitle(this.post, this.forum);

  final ApiForum forum;
  final ApiPost post;

  @override
  Widget build(BuildContext context) {
    if (post.title == null || post.title.isEmpty) return SizedBox.shrink();

    return forum.postTitleBuilder != null
        ? forum.postTitleBuilder(forum, post, 'view')
        : Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Text(
              '${post.title}',
              key: ValueKey(FirelampKeys.element.postTitle),
              style: stylePostTitle,
            ),
          );
  }
}
