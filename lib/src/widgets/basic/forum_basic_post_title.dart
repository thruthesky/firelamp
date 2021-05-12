import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class ForumBasicPostTitle extends StatelessWidget {
  const ForumBasicPostTitle(
    this.post, {
    @required this.onTap,
    Key key,
  }) : super(key: key);

  final ApiPost post;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        post.user.photoUrl,
        size: 60,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(post.user.name),
          Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 5),
          Text(
            post.shortDateTime,
            style: TextStyle(fontSize: Space.xsm),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
