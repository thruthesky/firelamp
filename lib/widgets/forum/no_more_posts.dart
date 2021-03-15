import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class NoMorePosts extends StatelessWidget {
  const NoMorePosts({Key key, @required this.forum}) : super(key: key);

  final ApiForum forum;

  @override
  Widget build(BuildContext context) {
    return forum.noMorePosts
        ? SafeArea(
            child: Text('No more posts'),
          )
        : SizedBox.shrink();
  }
}
