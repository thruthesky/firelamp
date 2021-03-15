import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoteButtons extends StatefulWidget {
  VoteButtons({
    @required this.postOrComment,
    this.showLike = true,
    this.showDislike,
    this.onError,
  });

  final bool showLike;
  final bool showDislike;
  final dynamic postOrComment;
  final Function onError;

  @override
  _VoteButtonsState createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  onVoteSuccess(dynamic re) {
    widget.postOrComment.y = re.y;
    widget.postOrComment.n = re.n;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // String likeText = "Like" + (widget.postOrComment.y > 0 ? "(${widget.postOrComment.y})" : "");
    // String dislikeText =
    //     "Dislike" + (widget.postOrComment.n > 0 ? "(${widget.postOrComment.n})" : "");

    return widget.showLike && widget.showDislike
        ? Container(
            child: Row(
            children: [
              if (widget.showLike)
                TextButton(
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: Color(0xff8cff82), size: 20),
                      if (widget.postOrComment.y > 0) ...[
                        SizedBox(width: Space.xs),
                        Text(
                          '${widget.postOrComment.y}',
                          style: TextStyle(fontSize: Space.sm, color: Colors.black54),
                        )
                      ],
                    ],
                  ),
                  onPressed: () async {
                    try {
                      final re = await Api.instance.vote(widget.postOrComment, 'Y');
                      onVoteSuccess(re);
                    } catch (e) {
                      if (widget.onError != null) widget.onError(e);
                    }
                  },
                ),
              if (widget.showDislike)
                TextButton(
                  child: Row(
                    children: [
                      Icon(Icons.thumb_down_outlined, color: Color(0xffff7575), size: 20),
                      if (widget.postOrComment.n > 0) ...[
                        SizedBox(width: Space.xs),
                        Text(
                          '${widget.postOrComment.n}',
                          style: TextStyle(fontSize: Space.sm, color: Colors.black54),
                        )
                      ],
                    ],
                  ),
                  onPressed: () async {
                    try {
                      final re = await Api.instance.vote(widget.postOrComment, 'N');
                      onVoteSuccess(re);
                    } catch (e) {
                      if (widget.onError != null) widget.onError(e);
                    }
                  },
                ),
            ],
          ))
        : SizedBox.shrink();
  }
}
