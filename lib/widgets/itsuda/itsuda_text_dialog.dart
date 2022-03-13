import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:firelamp/widgets/defines.dart';

class ItsudaTextDialog extends StatelessWidget {
  const ItsudaTextDialog({
    Key key,
    this.title = '있;수다!',
    @required this.content,
    this.subContent,
    // @required this.okButton,
  }) : super(key: key);

  final String title;
  final String content;
  final String subContent;
  // final Function okButton;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(Space.sm, Space.sm, Space.sm, Space.xs),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Space.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(Space.xs),
              child: Row(
                children: [
                  Icon(MaterialCommunityIcons.chat, size: 30),
                  SizedBox(width: Space.xsm),
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(Space.xxs),
              child: Center(child: Text(content, style: TextStyle(fontSize: 20))),
            ),
            if (subContent != null)
              Container(
                padding: EdgeInsets.all(Space.xxs),
                child: Center(child: Text(subContent, style: TextStyle(fontSize: 20))),
              ),
            Container(
                padding: EdgeInsets.all(Space.xs), child: Divider(color: Colors.black, height: 1)),
            TextButton(
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  textStyle: TextStyle(fontSize: 20),
                  padding: EdgeInsets.symmetric(horizontal: Space.lg)),
              onPressed: () => Get.back(result: true),
              child: Text('confirm'.tr, style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
