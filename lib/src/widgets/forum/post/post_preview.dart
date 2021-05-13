import 'package:firelamp/src/widget.keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

class PostPreview extends StatelessWidget {
  PostPreview(this.post, this.forum, {this.onTap, this.index});
  final ApiPost post;
  final ApiForum forum;
  final Function? onTap;
  final int? index;

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      '${post.title}',
      style: stylePostTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return GestureDetector(
      key: ValueKey("${FirelampKeys.element.postPreview}$index"),
      behavior: HitTestBehavior.opaque,
      onTap: onTap as void Function()?,
      child: forum.listView == 'gallery'
          ? PostGalleryPreview(post, forum)
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
                              post.files![0].url,
                              width: 100,
                              height: 80,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: -10,
                            child: forum.postAvatarBuilder == null
                                ? UserAvatar(post.user!.photoUrl, size: 40)
                                : forum.postAvatarBuilder!(post),
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
                              if (!post.hasFiles && forum.listView == 'thumbnail' || forum.listView == 'text') ...[
                                forum.postAvatarBuilder == null
                                    ? UserAvatar(post.user!.photoUrl, size: 65)
                                    : forum.postAvatarBuilder!(post),
                                SizedBox(width: Space.xsm),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.user!.nicknameOrName!),
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
