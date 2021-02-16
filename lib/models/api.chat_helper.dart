part of '../firelamp.dart';

class ChatHelper {
  String get myUid => Api.instance.md5;

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

  int pageNo = 0;
  int _limit = 20;

  /// Returns login user's room list collection `/chat/rooms` reference.
  /// Or, returns reference of my room (that has last message of the room)
  DatabaseReference myRoomsRef({String roomId}) {
    final ref = roomsRef(myUid);
    if (roomId == null)
      return ref;
    else
      return ref.child(roomId);
  }

  /// Return the reference of `/chat/messages/roomId` under which lots are messages are stored.
  DatabaseReference messagesRef(String roomId) {
    return Api.instance.database.reference().child('chat/messages').child(roomId);
  }

  /// Returns `/chat/rooms/{user-id}` reference.
  ///
  /// if [roomId] is given, it returns a reference of a room. Not the list.
  DatabaseReference roomsRef(String userId, {String roomId}) {
    final chatRoomsUserIdRef = Api.instance.database.reference().child('chat/rooms').child(userId);
    if (roomId == null)
      return chatRoomsUserIdRef;
    else
      return chatRoomsUserIdRef.child(roomId);
  }

  /// Returns one of login user's room document. Not reference.
  Future<ApiRoom> myRoom(String roomId) async {
    DataSnapshot snapshot = await myRoomsRef(roomId: roomId).once();
    return ApiRoom.fromSnapshot(snapshot);
  }

  myRoomRef(String roomId) {
    return myRoomsRef(roomId: roomId);
  }

  text(Map<String, dynamic> message) {
    String text = message['text'] ?? '';
    if (text == ChatProtocol.roomCreated) {
      text = 'Chat room created. ';
    }

    /// Display `no more messages` only when user scrolled up to see more messages.
    else if (pageNo > 1 && noMoreMessage) {
      text = 'No more messages. ';
    } else if (text == ChatProtocol.enter) {
      // print(message);
      text = "${message['displayName']} invited ${message['newUsers']}";
    }
    return text;
  }

  /// Translate text if it is chat protocol.
  /// ! @todo translate
  translateIfChatProtocol(String text) {
    if (text == null) return '';
    if (text.indexOf('ChatProtocol.') != -1) {
      return text.tr;
    } else {
      return text;
    }
  }
}
