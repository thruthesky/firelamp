import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoMorePosts extends StatelessWidget {
  const NoMorePosts({Key key, @required this.forum}) : super(key: key);

  final ApiForum forum;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Text('no_more_posts'.tr),
    );
  }
}
