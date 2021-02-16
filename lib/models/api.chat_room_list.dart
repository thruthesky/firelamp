part of '../firelamp.dart';

/// Chat room list helper class
///
/// This is a completely independent helper class to help to list login user's room list.
/// You may rewrite your own helper class.
class ChatRoomList extends ChatHelper {
  Function onChange;

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
  List<ApiChatUserRoom> rooms = [];

  ChatRoomList({
    @required Function onChange,
  }) {
    this.onChange = onChange;
    listenRoomList();
  }

  reset() {
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
    ///
    _myRoomListSubscription = myRoomsRef().onValue.listen((event) {
      fetched = true;
      Map<dynamic, dynamic> res = event.snapshot.value;
      rooms = [];
      res.forEach((key, data) {
        rooms.add(ApiChatUserRoom.fromData(data, key));
      });
      if (onChange != null) onChange();
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
