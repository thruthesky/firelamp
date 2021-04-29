import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/cupertino.dart';

class PostContent extends StatelessWidget {
  PostContent(this.post, this.forum);

  final ApiForum forum;
  final ApiPost post;

  @override
  Widget build(BuildContext context) {
    if (post.content == null || post.content.isEmpty) return SizedBox.shrink();

    return forum.postContentBuilder != null
        ? forum.postContentBuilder(forum, post, 'view')
        : Padding(
            padding: EdgeInsets.only(bottom: Space.sm),
            child: Text(
              '${post.content}',
              key: ValueKey(FirelampKeys.element.postContent),
              style: TextStyle(fontSize: Space.sm, wordSpacing: 2),
            ),
          );
  }
}
