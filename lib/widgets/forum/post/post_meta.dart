import 'package:firelamp/widgets/defines.dart';
// import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class PostMeta extends StatelessWidget {
  PostMeta(
    this.post,
    this.forum, {
    this.showAvatar = false,
    this.isInlineName = false,
    this.iconColor = const Color(0xffbadbd8),
  });

  final ApiPost post;
  final ApiForum forum;
  final bool showAvatar;
  final bool isInlineName;
  final Color iconColor;

  bool get showName {
    return post.files.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Widget name = Text(
    //   post.user.name,
    //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: Space.sm),
    // );

    // List<Widget> otherMeta = [
    //   Text(post.shortDateTime, style: TextStyle(fontSize: Space.xsm)),
    //   SizedBox(width: Space.xs),
    //   Icon(Icons.circle, size: Space.xxs, color: Colors.blueAccent),
    //   SizedBox(width: Space.xs),
    //   Text('${post.categoryIdx}', style: TextStyle(fontSize: Space.xsm)),
    //   SizedBox(width: Space.xs),
    // ];

    return Container(
      child: Row(
        children: [
          if (isInlineName) ...[
            Text('${post.user.name}', style: TextStyle(fontSize: Space.xsm)),
            SizedBox(width: Space.sm),
          ],
          Text('${post.shortDateTime}.', style: TextStyle(fontSize: Space.sm)),
          SizedBox(width: Space.sm),
          if (post.comments.isNotEmpty) ...[
            Icon(Icons.chat_bubble_outlined, size: Space.sm, color: iconColor),
            SizedBox(width: Space.xs),
            Text('${post.comments.length}'),
            SizedBox(width: Space.sm),
          ],
          if (forum.showLike && post.y > 0) ...[
            Icon(Icons.thumb_up_rounded, size: Space.sm, color: iconColor),
            SizedBox(width: Space.xs),
            Text('${post.y}'),
            SizedBox(width: Space.sm),
          ],
          if (forum.showDislike && post.n > 0) ...[
            Icon(Icons.thumb_down_rounded, size: Space.sm, color: iconColor),
            SizedBox(width: Space.xs),
            Text('${post.n}')
          ]
        ],
      ),
      // child: Row(
      //   children: [
      //     if (showAvatar) ...[
      //       UserAvatar(post.user.photoUrl, size: 40),
      //       SizedBox(width: Space.sm),
      //     ],
      //     if (isInlineName || post.display)
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [name, SizedBox(height: Space.xxs), Row(children: otherMeta)],
      //       ),
      //     if (isInlineName == false && post.display == false)
      //       Row(
      //         children: [
      //           if (showName) ...[
      //             name,
      //             SizedBox(width: Space.xs),
      //             Icon(
      //               Icons.circle,
      //               size: Space.xxs,
      //               color: Colors.blueAccent,
      //             ),
      //             SizedBox(width: Space.xs),
      //           ],
      //           ...otherMeta
      //         ],
      //       ),
      //   ],
      // ),
    );
  }
}
