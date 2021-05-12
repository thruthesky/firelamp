import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';
import 'package:get/get.dart';

class CommentList extends StatefulWidget {
  CommentList({
    this.post,
    this.forum,
    this.onError,
    this.rerenderParent,
  });
  final ApiPost post;
  final ApiForum forum;
  final Function onError;
  final Function rerenderParent;

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  String get listText {
    final commentCount = widget.post.comments.length;
    final text = '$commentCount comment';
    return commentCount > 1 ? text + 's' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.post.comments.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Space.xsm),
                Text(listText, style: TextStyle(fontSize: Space.xsm, color: Colors.grey[500])),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.post.comments.length,
                    itemBuilder: (_, i) {
                      if (widget.forum.commentVisibility != null) {
                        if (widget.forum.commentVisibility(widget.post.comments[i]) == false) {
                          return SizedBox.shrink();
                        }
                      }
                      return CommentView(
                        comment: widget.post.comments[i],
                        post: widget.post,
                        forum: widget.forum,
                        onError: widget.onError,
                        rerenderParent: () {
                          setState(() {});
                          if (widget.rerenderParent != null) widget.rerenderParent();
                        },
                        index: i,
                      );
                    }),
              ],
            )
          : Padding(
              padding: EdgeInsets.only(top: Space.xsm, left: Space.xsm),
              child: Text(
                'no_comments_yet'.tr,
                style: TextStyle(fontSize: Space.xsm, color: Colors.grey[500]),
              ),
            ),
    );
  }
}
