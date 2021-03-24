import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class CommentMeta extends StatelessWidget {
  final ApiComment comment;
  CommentMeta(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.user.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Space.sm,
            ),
          ),
          SizedBox(height: Space.xs),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: Space.xxs,
                color: Colors.blueAccent,
              ),
              SizedBox(width: Space.xs),
              Text(
                comment.shortDateTime,
                style: TextStyle(fontSize: Space.xsm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
