import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnSelectedFunction(dynamic selected);

class PopUpButton extends StatelessWidget {
  final OnSelectedFunction onSelected;
  final List<PopupMenuItem> items;
  final Widget icon;

  PopUpButton({
    @required this.items,
    @required this.onSelected,
    this.icon = const Icon(Icons.more_vert),
  }) : assert(icon != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<dynamic>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        itemBuilder: (context) => items,
        icon: icon,
        offset: Offset(10.0, 10.0),
        onSelected: onSelected,
      ),
    );
  }
}
