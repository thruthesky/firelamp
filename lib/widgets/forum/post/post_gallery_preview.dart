import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/shared/display_files.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:flutter/cupertino.dart';

class PostGalleryPreview extends StatelessWidget {
  PostGalleryPreview(this.post, this.forum);

  final ApiPost post;
  final ApiForum forum;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(post.user.photoUrl),
            SizedBox(width: Space.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${post.title}',
                      style: stylePostTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: Space.xxs),
                  PostMeta(post, forum, isInlineName: true),
                ],
              ),
            )
          ],
        ),
        if (post.hasFiles) ...[SizedBox(height: Space.xsm), DisplayFiles(postOrComment: post)],
      ],
    );
  }
}
