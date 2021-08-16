import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class PostMeta extends StatelessWidget {
  PostMeta(
    this.post,
    this.forum, {
    this.showAvatar = false,
    this.isInlineName = false,
    this.iconColor = const Color(0xFFFFdd00),
  });

  final ApiPost post;
  final ApiForum forum;
  final bool showAvatar;
  final bool isInlineName;
  final Color iconColor;

  bool get showName {
    return post.files.isNotEmpty;
  }

  int get commentCount {
    return post.comments.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (isInlineName && post.user.name.isNotEmpty) ...[
            Text('${post.user.name}',
                style: TextStyle(fontSize: Space.xsm, fontWeight: FontWeight.w500)),
            SizedBox(width: Space.sm),
          ],
          if (post.subcategory.isNotEmpty) ...[
            Text('[ ${post.subcategory} ]',
                style: TextStyle(fontSize: Space.xsm, fontWeight: FontWeight.w500)),
            SizedBox(width: Space.sm),
          ],
          Text('${post.shortDateTime}', style: TextStyle(fontSize: Space.xsm)),
          SizedBox(width: Space.sm),
          if (post.comments.isNotEmpty) ...[
            Icon(Icons.chat_bubble_outlined, size: Space.xsm, color: iconColor),
            SizedBox(width: Space.xs),
            Text('$commentCount', style: TextStyle(fontSize: Space.xsm)),
            SizedBox(width: Space.xsm),
          ],
          Text(
            'No. ${post.idx}',
            style: TextStyle(fontSize: Space.xsm),
          ),
        ],
      ),
    );
  }
}
