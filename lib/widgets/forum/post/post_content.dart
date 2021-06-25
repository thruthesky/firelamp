import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class PostContent extends StatelessWidget {
  PostContent(
    this.post,
    this.forum, {
    this.maxLines,
    this.overflow,
    this.buildFor = 'list',
    this.style = const TextStyle(fontSize: Space.sm, wordSpacing: 2),
    this.padding = const EdgeInsets.only(bottom: Space.sm),
  });

  final ApiForum forum;
  final ApiPost post;
  final int maxLines;
  final TextOverflow overflow;
  final TextStyle style;
  final EdgeInsets padding;

  /// [buildFor] can be `view` or `list`
  /// it is set as `list` by default
  final String buildFor;

  @override
  Widget build(BuildContext context) {
    if (buildFor == 'view' && (post.content == null || post.content.isEmpty))
      return SizedBox.shrink();

    return forum.postContentBuilder != null
        ? forum.postContentBuilder(forum, post, buildFor)
        : Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: post.content,
            linkStyle: TextStyle(color: Colors.blue),
          );

    // Padding(
    //   padding: padding,
    //   child: Text(
    //     '${post.content}',
    //     key: ValueKey(FirelampKeys.element.postContent),
    //     style: style,
    //     maxLines: maxLines,
    //     overflow: overflow,
    //   ),
    // );
  }
}
