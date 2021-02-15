part of '../firelamp.dart';

/// Chat room list helper class
///
/// This is a completely independent helper class to help to list login user's room list.
/// You may rewrite your own helper class.
class ChatMyRoomList extends ChatHelper {
  Function __render;

  StreamSubscription _myRoomListSubscription;
  List<StreamSubscription> _roomSubscriptions = [];

  /// [fetched] becomes true after it fetches the room list. the room list might
  /// be empty if there is no chat room for the user.
  ///
  /// ```dart
  /// myRoomList?.fetched != true ? Spinner() : ListView.builder( ... );
  /// ```
  bool fetched = false;

  /// My room list including room id.
  List<ChatUserRoom> rooms = [];
  String _order = "";
  ChatMyRoomList({
    @required Function render,
    String order = "createdAt",
  })  : __render = render,
        _order = order {
    listenRoomList();
  }

  _notify() {
    if (__render != null) __render();
  }

  reset({String order}) {
    if (order != null) {
      _order = order;
    }

    rooms = [];
    _myRoomListSubscription.cancel();
    listenRoomList();
  }

  /// Listen to global room updates.
  ///
  /// Listen for;
  /// - title changes,
  /// - users array changes,
  /// - and other properties change.
  listenRoomList() {
    _myRoomListSubscription = myRoomsRef().onValue.listen((event) {
      fetched = true;
      Map<dynamic, dynamic> res = event.snapshot.value;
      res.forEach((key, data) {
        final roomInfo = ChatUserRoom.fromData(data, key);
        rooms.add(roomInfo);
      });
      _notify();
    });
  }

  leave() {
    if (_myRoomListSubscription != null) _myRoomListSubscription.cancel();
    if (_roomSubscriptions.isNotEmpty) {
      _roomSubscriptions.forEach((element) {
        element.cancel();
      });
    }
  }
}
