import 'package:flutter/material.dart';

class RoundedBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin, padding;
  final Color boxColor;
  final double radius;

  RoundedBox({
    this.child,
    this.margin,
    this.padding,
    this.radius = 20,
    boxColor,
  }) : this.boxColor = boxColor ?? Colors.grey[300];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: child,
    );
  }
}
