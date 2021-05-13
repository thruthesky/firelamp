
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

class LoginFirstScaffold extends StatefulWidget {
  LoginFirstScaffold({this.title = 'Login', this.endDrawer});
  final String title;
  final Widget? endDrawer;
  @override
  _LoginFirstScaffoldState createState() => _LoginFirstScaffoldState();
}

class _LoginFirstScaffoldState extends State<LoginFirstScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      endDrawer: widget.endDrawer,
      body: LoginFirst(),
    );
  }
}
