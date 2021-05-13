import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class PostTitle extends StatelessWidget {
  PostTitle(
    this.post,
    this.forum, {
    this.maxLines,
    this.overflow,
    this.style = stylePostTitle,
    this.buildFor = 'list',
    this.padding = const EdgeInsets.only(bottom: Space.sm),
  });

  final ApiForum? forum;
  final ApiPost? post;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle style;
  final EdgeInsets padding;

  /// [buildFor] can be `view` or `list`
  /// it is set as `list` by default
  final String buildFor;

  @override
  Widget build(BuildContext context) {
    if (buildFor == 'view' && (post!.title == null || post!.title!.isEmpty)) return SizedBox.shrink();

    return forum!.postTitleBuilder != null
        ? forum!.postTitleBuilder!(forum, post, buildFor)
        : Padding(
            padding: padding,
            child: Text(
              '${post!.title}',
              key: ValueKey(FirelampKeys.element.postTitle),
              style: style,
              maxLines: maxLines,
              overflow: overflow,
            ),
          );
  }
}
