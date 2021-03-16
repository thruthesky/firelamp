import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/user/user_avatar.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class PostMeta extends StatelessWidget {
  PostMeta(
    this.post, {
    this.showAvatar = false,
    this.isInlineName = false,
  });

  final ApiPost post;
  final bool showAvatar;
  final bool isInlineName;

  bool get showName {
    return post.files.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    Widget name = Text(
      post.user.name,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: Space.sm),
    );

    List<Widget> otherMeta = [
      Text(post.shortDateTime, style: TextStyle(fontSize: Space.xsm)),
      SizedBox(width: Space.xs),
      Icon(Icons.circle, size: Space.xxs, color: Colors.blueAccent),
      SizedBox(width: Space.xs),
      Text('${post.categoryIdx}', style: TextStyle(fontSize: Space.xsm)),
      SizedBox(width: Space.xs),
      // Text('${post.display}', style: TextStyle(fontSize: Space.xsm)),
    ];

    return Container(
      child: Row(
        children: [
          if (showAvatar) ...[
            UserAvatar(post.user.photoUrl, size: 40),
            SizedBox(width: Space.sm),
          ],
          if (isInlineName || post.display)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [name, SizedBox(height: Space.xxs), Row(children: otherMeta)],
            ),
          if (isInlineName == false && post.display == false)
            Row(
              children: [
                if (showName) ...[
                  name,
                  SizedBox(width: Space.xs),
                  Icon(
                    Icons.circle,
                    size: Space.xxs,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: Space.xs),
                ],
                ...otherMeta
              ],
            ),
        ],
      ),
    );
  }
}
