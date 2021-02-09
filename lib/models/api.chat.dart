part of '../firelamp.dart';

class ApiChat {
  /// [talkingTo] is the other user's document key that the login user is talking to.
  String talkingTo;
  enter({@required String userId}) async {
    final user = await Api.instance.otherUserProfile(userId);
    final String otherId = user.md5;

    /// @todo create `chat/rooms/myId/otherId` if not exists.
    /// @todo create `chat/rooms/otherId/myId` if not exists.
    /// @todo send message to `chat/message/myId/otherId` with protocol roomCreated
    /// @todo send message to `chat/message/otherId/myId` with protocol roomCreated
    /// @todo update chat room `chat/rooms/myId/otherId`. increase newMessage and stamp.
    /// @todo update chat room `chat/rooms/otherId/myId`. increase newMessage and stamp.

    talkingTo = otherId;

    /// @todo send push notification
  }

  ///
  send({
    @required String text,
    String url,
    String urlType,
  }) {
    ///
  }
}
