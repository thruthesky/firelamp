import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/material.dart';

class AdminReady extends StatelessWidget {
  AdminReady({@required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final api = Api.instance;
    return StreamBuilder(
      stream: api.authChanges,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Spinner();
        if (snapshot.hasError) return Text('AdminReady => Snapshot => 에러');
        if (api.notLoggedIn)
          return Column(
            children: [
              Text('로그인을 해 주세요.'),
            ],
          );
        if (api.user.admin == false)
          return Column(
            children: [
              Text('관리자가 아닙니다.'),
            ],
          );
        return child;
      },
    );
  }
}
