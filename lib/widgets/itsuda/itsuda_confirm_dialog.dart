import 'package:firelamp/widgets/defines.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firelamp/widgets/itsuda/half_circle_clipper.dart';

class ItsudaConfirmDialog extends StatelessWidget {
  const ItsudaConfirmDialog({
    Key key,
    @required this.title,
    this.subTitle,
    @required this.content,
    this.okButton,
    this.okButtonText = '확인',
    this.cancelButton,
    this.cancelButtonText = '취소',
    this.alignment = 'start',
  }) : super(key: key);

  final String title;
  final String subTitle;
  final Widget content;
  final Function okButton;
  final String okButtonText;
  final Function cancelButton;
  final String cancelButtonText;
  final String alignment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ClipPath(
        clipper: HalfCircleClipper(right: (Get.width - 130) * 0.5, holeRadius: 50),
        child: Container(
          padding:
              EdgeInsets.only(left: Space.md, top: Space.md, right: Space.md, bottom: Space.sm),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Space.md),
          ),
          child: Column(
            crossAxisAlignment: alignment == 'start'
                ? CrossAxisAlignment.start
                : alignment == 'end'
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(MaterialCommunityIcons.chat, size: 30),
                  SizedBox(width: Space.xsm),
                  Text(title, style: TextStyle(fontSize: 20).copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              if (subTitle != null)
                Column(
                  children: [
                    SizedBox(width: Space.xsm),
                    Container(
                      width: double.infinity,
                      child: Text(subTitle, style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              SizedBox(width: Space.xsm),
              content,
              SizedBox(width: Space.xsm),
              Divider(color: Colors.black, height: 1),
              SizedBox(width: Space.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.black, textStyle: TextStyle(fontSize: 20)),
                        onPressed: cancelButton ?? () => Get.back(),
                        child: Text(cancelButtonText)),
                  ),
                  Expanded(
                    child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.black, textStyle: TextStyle(fontSize: 20)),
                        onPressed: () => okButton(),
                        child: Text(okButtonText)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
