
import 'package:flutter/material.dart';
import 'package:firelamp/firelamp.dart';

class UserAvatar extends StatelessWidget {
  UserAvatar(
    this.url, {
    this.size = 48,
    this.onTap,
    this.color,
  });
  final String url;
  final double size;
  final Function onTap;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        child: url == null || url == ''
            ? Icon(Icons.person)
            : ClipOval(
                child: CachedImage(url),
              ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 1.0, spreadRadius: 1.0),
          ],
        ),
      ),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
    );
  }
}
