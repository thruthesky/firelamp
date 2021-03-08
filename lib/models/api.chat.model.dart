part of '../firelamp.dart';

/// [ApiChatUserRoom] is the record reference of `/chat/rooms/{user.idx/roomId` information.
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

class ApiChatMessage {
  String id;
  int createdAt;
  String displayName;
  String profilePhotoUrl;
  String userId;
  String text;
  String protocol;
  bool isMine;
  bool isImage;

  ApiChatMessage({
    this.id,
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
    ///
    return ApiChatMessage(
      id: data['id'],
      createdAt: data['createdAt'],
      displayName: data['displayName'],
      profilePhotoUrl: data['profilePhotoUrl'],
      userId: data['userId'],
      text: data['text'],
      protocol: data['protocol'],
      isMine: data['userId'] == Api.instance.userIdx,
      isImage: isImageUrl(data['text']),
    );
  }
}
