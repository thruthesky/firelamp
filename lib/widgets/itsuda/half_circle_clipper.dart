import 'package:flutter/material.dart';

class HalfCircleClipper extends CustomClipper<Path> {
  HalfCircleClipper({this.right, this.holeRadius});

  final double right;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - right, size.height)
      ..arcToPoint(Offset(size.width - right - holeRadius, size.height),
          clockwise: false, radius: Radius.circular(1));

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(HalfCircleClipper oldClipper) => true;
}
