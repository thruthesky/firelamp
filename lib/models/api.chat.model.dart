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

class ApiChatMessage {
  int createdAt;
  String displayName;
  String profilePhotoUrl;
  String userId;
  String text;
  String protocol;
  bool isMine;
  bool isImage;

  ApiChatMessage({
    this.createdAt,
    this.displayName,
    this.profilePhotoUrl,
    this.userId,
    this.text,
    this.isMine,
    this.isImage,
    this.protocol,
  });
  factory ApiChatMessage.fromData(Map<dynamic, dynamic> data) {
    bool isImage = false;
    if (data['text'] != null) {
      String t = data['text'];
      if (t.startsWith('http://') || t.startsWith('https://')) {
        if (t.endsWith('.jpg') || t.endsWith('.jpeg') || t.endsWith('.gif') || t.endsWith('.png')) {
          isImage = true;
        }
      }
    }
    return ApiChatMessage(
      createdAt: data['createdAt'],
      displayName: data['displayName'],
      profilePhotoUrl: data['profilePhotoUrl'],
      userId: data['userId'],
      text: data['text'],
      protocol: data['protocol'],
      isMine: data['userId'] == Api.instance.id,
      isImage: isImage,
    );
  }
}

/// [ApiChatUserRoom] is the record reference of `/chat/rooms/{user.md5}` information.
class ApiChatUserRoom {
  String id;
  String userId;
  String displayName;
  String profilePhotoUrl;
  String text;

  /// It will be `ServerValue.TimeStamp` when it sends the
  /// message. And it will `Timestamp` when it read the room information.
  dynamic createdAt;

  /// [newMessages] has the number of new messages for that room.
  int newMessages;

  ApiChatUserRoom({
    this.id,
    this.userId,
    this.displayName,
    this.profilePhotoUrl,
    this.createdAt,
    this.newMessages,
    this.text,
  });

  factory ApiChatUserRoom.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot == null) return null;
    Map<dynamic, dynamic> info = snapshot.value;
    return ApiChatUserRoom.fromData(info, snapshot.key);
  }

  factory ApiChatUserRoom.fromData(Map<dynamic, dynamic> info, [String id]) {
    if (info == null) return ApiChatUserRoom();

    String _text = info['text'];
    return ApiChatUserRoom(
      id: id,
      userId: info['userId'],
      displayName: info['displayName'],
      profilePhotoUrl: info['profilePhotoUrl'],
      createdAt: info['createdAt'],
      newMessages: info['newMessages'],
      text: _text,
    );
  }

  Map<String, dynamic> get data {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': this.createdAt,
      'newMessages': this.newMessages,
      'text': this.text,
    };
  }

  @override
  String toString() {
    return data.toString();
  }
}