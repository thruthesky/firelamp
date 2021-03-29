import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/shared/display_files.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostPreview extends StatelessWidget {
  PostPreview(this.post, this.forum, {this.onTap, this.index});
  final ApiPost post;
  final ApiForum forum;
  final Function onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      '${post.title}',
      style: stylePostTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return GestureDetector(
      key: ValueKey("${FirelampWidgetKeys.postPreview}$index"),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: forum.listView == 'gallery'
          ? Column(
              children: [
                Row(
                  children: [
                    UserAvatar(post.user.photoUrl),
                    SizedBox(width: Space.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          SizedBox(height: Space.xxs),
                          PostMeta(post, forum, isInlineName: true),
                        ],
                      ),
                    )
                  ],
                ),
                if (post.hasFiles) ...[
                  SizedBox(height: Space.xsm),
                  DisplayFiles(postOrComment: post),
                ],
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
                            top: kIsWeb ? -6 : -10,
                            child: UserAvatar(post.user.photoUrl, size: 40),
                          ),
                        ],
                      ),
                      SizedBox(width: Space.xsm),
                    ],
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (!post.hasFiles && forum.listView == 'thumbnail' ||
                                  forum.listView == 'text') ...[
                                UserAvatar(post.user.photoUrl, size: 65),
                                SizedBox(width: Space.xsm),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${post.user.name}'),
                                    title,
                                    SizedBox(height: Space.xxs),
                                    Text(
                                      '${post.content}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: Space.xs),
                          Padding(
                            child: PostMeta(post, forum),
                            padding: EdgeInsets.only(left: Space.xxs),
                          ),
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
