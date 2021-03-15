import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/material.dart';

class LoginFirst extends StatefulWidget {
  @override
  _LoginFirstState createState() => _LoginFirstState();
}

class _LoginFirstState extends State<LoginFirst> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(width: Space.xxl, height: Space.xxl),
          Center(
            child: Text('Login first!!'),
          ),
        ],
      ),
    );
  }
}
