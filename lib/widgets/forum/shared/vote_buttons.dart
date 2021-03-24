import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoteButtons extends StatefulWidget {
  VoteButtons(
    this.postOrComment,
    this.forum, {
    this.onError,
  });
  final ApiForum forum;
  final dynamic postOrComment;
  final Function onError;

  @override
  _VoteButtonsState createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  onVote(String choice) async {
    if (Api.instance.notLoggedIn) return widget.onError('login_first'.tr);

    try {
      final re = await Api.instance.vote(widget.postOrComment, choice);
      onVoteSuccess(re);
    } catch (e) {
      if (widget.onError != null) widget.onError(e);
    }
  }

  onVoteSuccess(dynamic re) {
    widget.postOrComment.y = re.y;
    widget.postOrComment.n = re.n;
    widget.forum.render();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.forum.showLike || widget.forum.showDislike
        ? Container(
            child: Row(
            children: [
              if (widget.forum.showLike)
                Padding(
                  padding: EdgeInsets.only(left: Space.xsm, right: Space.md),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Color(0xff8cff82),
                          size: 20,
                        ),
                        if ("${widget.postOrComment.y}".toInt > 0) ...[
                          SizedBox(width: Space.xs),
                          Text(
                            '${widget.postOrComment.y}',
                            style: TextStyle(fontSize: Space.sm, color: Colors.black54),
                          )
                        ],
                      ],
                    ),
                    onTap: () => onVote('Y'),
                  ),
                ),
              if (widget.forum.showDislike)
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.forum.showLike ? 0 : Space.xsm,
                    right: Space.sm,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(Icons.thumb_down_outlined, color: Color(0xffff7575), size: 20),
                        if ("${widget.postOrComment.n}".toInt > 0) ...[
                          SizedBox(width: Space.xs),
                          Text(
                            '${widget.postOrComment.n}',
                            style: TextStyle(fontSize: Space.sm, color: Colors.black54),
                          )
                        ],
                      ],
                    ),
                    onTap: () => onVote('N'),
                  ),
                ),
            ],
          ))
        : SizedBox.shrink();
  }
}
