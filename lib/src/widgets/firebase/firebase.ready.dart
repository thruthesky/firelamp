import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class FirebaseReady extends StatelessWidget {
  FirebaseReady({this.builder});
  final Function? builder;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Api.instance!.firebaseInitialized,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return SizedBox.shrink();
          if (snapshot.data == true) {
            // print("FirebaseReady: snapshot.data: ${snapshot.data}");
            return this.builder!(context);
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
