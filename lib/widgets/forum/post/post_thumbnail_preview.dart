import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/post/post_content.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/forum/post/post_title.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostThumbnailPreview extends StatelessWidget {
  PostThumbnailPreview(this.post, this.forum, {this.onTap, this.avatarBuilder, Key key}) : super(key: key);

  final ApiPost post;
  final ApiForum forum;
  final Function onTap;
  final Function avatarBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (post.hasFiles) ...[
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImage(post.files[0].url, width: 100, height: 80),
                    ),
                    Positioned(
                        left: -15,
                        bottom: -15,
                        child: avatarBuilder != null
                            ? avatarBuilder(post, 40.0)
                            : UserAvatar(post.user.photoUrl, size: 40)),
                  ],
                ),
                SizedBox(width: Space.xsm),
              ],
              if (!post.hasFiles) ...[
                avatarBuilder != null ? avatarBuilder(post, 65.0) : UserAvatar(post.user.photoUrl, size: 65),
                SizedBox(width: Space.xsm),
              ],
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.user.nicknameOrName),
                              PostTitle(post, forum,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  padding: EdgeInsets.only(bottom: Space.xxs)),
                              PostContent(
                                post,
                                forum,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                padding: EdgeInsets.all(0),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: Space.xxs),
                    Padding(child: PostMeta(post, forum), padding: EdgeInsets.only(left: Space.xxs)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Divider(),
        ],
      ),
    );
  }
}
