part of '../firelamp.dart';

class ChatHelper {
  int get myIdx => Api.instance.userIdx;

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

  /// The [pageNo] is based on no. 1. The first page is 1.
  int pageNo = 0;
  int _limit = 20;

  /// Returns login user's room list collection `/chat/rooms` reference.
  /// Or, returns reference of my room (that has last message of the room)
  DatabaseReference myRoomsRef({String roomId}) {
    final ref = roomsRef(myIdx.toString());
    if (roomId == null)
      return ref;
    else
      return ref.child(roomId);
  }

  /// Return the reference of `/chat/messages/roomId` under which lots are messages are stored.
  DatabaseReference messagesRef(String roomId) {
    return Api.instance.database.reference().child('chat/messages').child(roomId);
  }

  /// Return the reference of `/chat/messages/roomId/id` under which lots are messages are stored.
  DatabaseReference messageRef(String roomId, String id) {
    return messagesRef(roomId).child(id);
  }

  /// Returns  DatabaseReference of  `/chat/rooms/{user-id}`
  /// Or `/chat/rooms/{user-id}/roomId`
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
  Future<ApiChatUserRoom> myRoom(String roomId) async {
    DataSnapshot snapshot = await myRoomsRef(roomId: roomId).once();
    return ApiChatUserRoom.fromSnapshot(snapshot);
  }

  myRoomRef(String roomId) {
    return myRoomsRef(roomId: roomId);
  }

  /// Translate text if it is chat protocol.
  /// ! @TODO translate
  translateIfChatProtocol(String text) {
    if (text == null) return '';
    if (text.indexOf('ChatProtocol.') != -1) {
      return text.tr;
    } else {
      return text;
    }
  }
}
