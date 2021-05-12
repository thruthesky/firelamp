import 'package:flutter/material.dart';

class CircleIcon extends StatelessWidget {
  CircleIcon(
      {@required this.icon,
      @required this.backgroundColor,
      @required this.onPressed});
  final Widget icon;
  final Color backgroundColor;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: icon,
          color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
