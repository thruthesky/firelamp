import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  UserInfo({required this.onLogout});
  final Function onLogout;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Email: ${Api.instance!.user!.email}'),
          Text('sesionId: ${Api.instance!.sessionId}'),
          ElevatedButton(
            onPressed: onLogout as void Function()?,
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
