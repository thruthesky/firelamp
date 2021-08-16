import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/popup_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PushNotificationIcon extends StatefulWidget {
  PushNotificationIcon(this.forum);
  final ApiForum forum;
  @override
  _PushNotificationIconState createState() => _PushNotificationIconState();
}

class _PushNotificationIconState extends State<PushNotificationIcon> {
  final api = Api.instance;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    initPushNotificationIcons();
  }

  initPushNotificationIcons() {
    if (widget.forum.categoryId == null || widget.forum.categoryId == 'noCategory') return;

    /// Get latest user's profile from backend
    if (api.loggedIn) {
      api.refreshProfile().then((profile) => setState(() => loading = false));
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.forum.categoryId != null
          ? Stack(
              alignment: AlignmentDirectional.center,
              children: [
                PopUpButton(
                  items: [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            api.isSubscribeTopic(NotificationOptions.post(widget.forum.categoryId))
                                ? Icons.notifications_on
                                : Icons.notifications_off,
                            color: Colors.blue,
                          ),
                          Text(' Post'),
                        ],
                      ),
                      value: 'post',
                    ),
                    PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              api.isSubscribeTopic(
                                      NotificationOptions.comment(widget.forum.categoryId))
                                  ? Icons.notifications_on
                                  : Icons.notifications_off,
                              color: Colors.blue,
                            ),
                            Text(' Comment'),
                          ],
                        ),
                        value: 'comment'),
                  ],
                  icon: Icon(Icons.notifications),
                  onSelected: onNotificationSelected,
                ),
                if (api.isSubscribeTopic(NotificationOptions.post(widget.forum.categoryId)))
                  Positioned(
                    top: 15,
                    left: 5,
                    child: Icon(Icons.comment, size: Space.xsm, color: Colors.greenAccent),
                  ),
                if (api.isSubscribeTopic(NotificationOptions.comment(widget.forum.categoryId)))
                  Positioned(
                    top: 15,
                    right: 5,
                    child: Icon(Icons.comment, size: Space.xsm, color: Colors.greenAccent),
                  ),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  onNotificationSelected(dynamic selection) async {
    if (api.notLoggedIn) {
      return Get.snackbar('Notifications', 'Must Login First');
    }

    /// Show spinner
    setState(() => loading = true);
    String topic;
    String title = "Notification";
    if (selection == 'post') {
      topic = NotificationOptions.post(widget.forum.categoryId);
      title = 'Post ' + title;
    } else if (selection == 'comment') {
      topic = NotificationOptions.comment(widget.forum.categoryId);
      title = 'Comment ' + title;
    }

    final ApiUser res = await api.subscribeOrUnsubscribeTopic(topic);

    /// Show spinner
    setState(() => loading = false);
    String msg = res.data[topic] == 'on' ? 'Subscribed' : 'Unsubscribed';
    Get.snackbar(title, msg);
  }
}
