import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

import 'package:firelamp/widgets/forum/comment/comment_view.dart';
import 'package:get/get.dart';

class CommentList extends StatefulWidget {
  CommentList({
    this.post,
    this.forum,
    this.onError,
  });
  final ApiPost post;
  final ApiForum forum;
  final Function onError;

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
                Text(
                  listText,
                  style: TextStyle(fontSize: Space.xsm, color: Colors.grey[500]),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.post.comments.length,
                  itemBuilder: (_, i) => CommentView(
                    comment: widget.post.comments[i],
                    post: widget.post,
                    forum: widget.forum,
                    onError: widget.onError,
                    rerenderParent: () => setState(() {}),
                    index: i,
                  ),
                ),

                // for (ApiComment comment in widget.post.comments)
                //   CommentView(
                //     comment: comment,
                //     post: widget.post,
                //     forum: widget.forum,
                //     onError: widget.onError,
                //     rerenderParent: () => setState(() {}),
                //   ),
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
