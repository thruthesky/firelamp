import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class FirebaseReady extends StatelessWidget {
  FirebaseReady({this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Api.instance.firebaseInitialized,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return SizedBox.shrink();
          // print("snapshot.data: ${snapshot.data}");
          if (snapshot.data == true) {
            return this.child;
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
