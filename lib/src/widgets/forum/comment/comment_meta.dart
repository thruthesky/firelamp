
import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class CommentMeta extends StatelessWidget {
  final ApiComment? comment;
  final ApiForum? forum;
  CommentMeta({required this.forum, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          forum!.commentNameBuilder != null
              ? forum!.commentNameBuilder!(comment)
              : Text(comment!.user!.nicknameOrName!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Space.sm,
                  )),
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
                comment!.shortDateTime!,
                style: TextStyle(fontSize: Space.xsm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
