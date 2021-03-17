import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/shared/files_view.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class PostPreview extends StatelessWidget {
  PostPreview(
    this.post,
    this.forum, {
    this.onTap,
  });
  final ApiPost post;
  final ApiForum forum;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: forum.listView == 'gallery'
          ? Column(
              children: [
                if (post.hasFiles) ...[
                  FilesView(postOrComment: post, isStaggered: true),
                  SizedBox(height: Space.sm),
                ],
                Row(
                  children: [
                    UserAvatar(post.user.photoUrl),
                    SizedBox(width: Space.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${post.user.name}'),
                        PostMeta(post, forum),
                      ],
                    )
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (post.hasFiles && forum.listView == 'thumbnail') ...[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImage(
                              post.files[0].url,
                              width: 100,
                              height: 80,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: -15,
                            child: UserAvatar(post.user.photoUrl, size: 40),
                          ),
                        ],
                      ),
                      SizedBox(width: Space.xsm),
                    ],
                    if (!post.hasFiles && forum.listView == 'thumbnail') ...[
                      Container(
                        constraints: BoxConstraints(minWidth: 70),
                        child: Column(
                          children: [
                            UserAvatar(post.user.photoUrl, size: 55),
                            SizedBox(height: Space.xs),
                            Text('${post.user.name}')
                          ],
                        ),
                      ),
                      SizedBox(width: Space.xsm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${post.user.name}'),
                          Text(
                            '${post.title}',
                            style: stylePostTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Space.xxs),
                          Text(
                            '${post.content}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Space.xxs),
                          PostMeta(post, forum),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
