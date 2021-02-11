part of '../firelamp.dart';

/// [ChatRoom] is a model (extending [ChatBase]) that represents the chat room under `/chat-global` collection.
/// All the chat room resides under this collection.
class ApiRoom {
  String roomId;
  String title;
  List<String> users;
  dynamic createdAt;
  dynamic updatedAt;

  /// [newMessages] has the number of new messages for that room.
  int newMessages;

  // String get otherUserId {
  //   // If there is no other user.
  //   return users.firstWhere(
  //     (el) => el != Api.instance.id,
  //     orElse: () => null,
  //   );
  // }

  ApiRoom({
    this.roomId,
    this.title,
    this.users,
    this.createdAt,
    this.newMessages,
  });

  factory ApiRoom.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot == null) return null;
    Map<dynamic, dynamic> info = snapshot.value;
    return ApiRoom.fromData(info, snapshot.key);
  }

  factory ApiRoom.fromData(Map<dynamic, dynamic> info, String id) {
    if (info == null) return ApiRoom();

    return ApiRoom(
      roomId: id,
      title: info['title'],
      users: List<String>.from(info['users'] ?? []),
      createdAt: info['createdAt'],
      newMessages: info['newMessages'],
    );
  }

  Map<String, dynamic> get data {
    return {
      'title': this.title,
      'users': this.users,
      'createdAt': this.createdAt,
      'newMessages': this.newMessages,
    };
  }

  @override
  String toString() {
    return data.toString();
  }
}
