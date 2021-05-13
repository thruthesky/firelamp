import 'package:firelamp/firelamp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentContent extends StatelessWidget {
  final ApiComment? comment;

  CommentContent(this.comment);

  @override
  Widget build(BuildContext context) {
    return comment!.content!.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(top: Space.sm),
            child: Text(
              '${comment!.content}',
              key: ValueKey(FirelampKeys.element.commentContent),
            ),
          )
        : SizedBox.shrink();
  }
}
