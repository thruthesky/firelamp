import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/post/post_meta.dart';
import 'package:firelamp/widgets/image.cache.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:flutter/cupertino.dart';

class PostThumbnailPreview extends StatelessWidget {
  PostThumbnailPreview(this.post, this.forum, {this.onTap});

  final ApiPost post;
  final ApiForum forum;
  final Function onTap;

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
                    Positioned(left: 10, top: -15, child: UserAvatar(post.user.photoUrl, size: 40)),
                  ],
                ),
                SizedBox(width: Space.xsm),
              ],
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (!post.hasFiles) ...[
                          UserAvatar(post.user.photoUrl, size: 65),
                          SizedBox(width: Space.xsm),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.user.nicknameOrName),
                              Text(
                                '${post.title}',
                                style: stylePostTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Space.xxs),
                              Text('${post.content}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: Space.xs),
                    Padding(
                        child: PostMeta(post, forum), padding: EdgeInsets.only(left: Space.xxs)),
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
