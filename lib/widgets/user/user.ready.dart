import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class UserReady extends StatelessWidget {
  UserReady({this.login, this.logout});
  final Widget login;
  final Widget logout;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Api.instance.authChanges,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return SizedBox.shrink();
          ApiUser user = snapshot.data;
          if (user == null) {
            return this.logout;
          } else {
            return this.login;
          }
        });
  }
}
