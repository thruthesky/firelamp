part of '../firelamp.dart';

/// Chat room message list helper class.
class ChatRoom {
  /// [render] will be called to notify chat room listener to re-render the screen.
  ///
  /// For one chat message sending,
  /// - [render] will be invoked 2 times on message sender's device due to offline support.
  /// - [render] will be invoked 1 times on receiver's device.
  ///
  /// [globalRoomChange] will be invoked when global chat room changes.
  ChatRoom({
    Function render,
  }) : _render = render;

  ApiUser otherUser;

  /// Room id
  String roomId;

  /// push notification topic name
  String get topic => 'notifyChat_${this.roomId}';

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

  int page = 0;
  int _limit = 30;

  /// When user scrolls to top to view previous messages, the app fires the scroll event
  /// too much, so it fetches too many batches(pages) at one time.
  /// [_throttle] reduces the scroll event to relax the fetch racing.
  /// [_throttle] is working together with [_throttling]
  /// 1500ms is recommended.
  int _throttle = 1500;

  bool _throttling = false;

  ///
  Function _render;

  StreamSubscription _chatRoomSubscription;
  StreamSubscription _currentRoomSubscription;

  /// Loaded the chat messages of current chat room.
  List<Map<dynamic, dynamic>> messages = [];

  /// [loading] becomes true while the app is fetching more messages.
  /// The app should display loader while it is fetching.
  bool loading = false;

  /// Global room info (of current room)
  /// Use this to dipplay title or other information about the room.
  /// When `/chat/global/room-list/{roomId}` changes, it will be updated and calls render handler.
  ///
  ChatRoomInfo chatRoomInfo;

  /// Chat room properties
  String get id => chatRoomInfo?.roomId;
  String get title => chatRoomInfo?.title;
  List<String> get users => chatRoomInfo?.users;
  Timestamped get createdAt => chatRoomInfo.createdAt;

  /// Enter chat room
  Future<void> enter(String userId) async {
    otherUser = await Api.instance.otherUserProfile(userId);

    roomId = otherUser.data['roomId'];

    ///create `chat/rooms/myId/roomId` if not exists.
    ///create `chat/rooms/otherId/roomId` if not exists.
    DataSnapshot snapshot = await Api.instance.userRoomRef(Api.instance.md5, roomId).once();
    print('userRoomRef(${Api.instance.md5}, ${otherUser.data['roomId']})');
    print(snapshot);
    if (snapshot.value == null) {
      await Api.instance.userRoomRef(Api.instance.md5, roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'senderId': otherUser.id,
        'senderDisplayName': otherUser.nickname,
        'senderprofilePhotoUrl': otherUser.profilePhotoUrl,
      });
      await Api.instance.userRoomRef(otherUser.md5, roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'senderId': Api.instance.id,
        'senderDisplayName': Api.instance.nickname,
        'senderprofilePhotoUrl': Api.instance.profilePhotoUrl,
      });

      /// send message to `chat/message/roomId` with protocol roomCreated
      ///   await sendMessage(text: ChatProtocol.roomCreated, displayName: loginUserId);
      await Api.instance.chatMessagesRef(roomId).push().set({
        'createdAt': ServerValue.timestamp,
        'senderId': Api.instance.id,
        'senderDisplayName': Api.instance.nickname,
        'senderprofilePhotoUrl': Api.instance.profilePhotoUrl,
        'protocol': ChatProtocol.roomCreated
      });
    }

    //   /// @todo update chat room `chat/rooms/myId/otherId`. increase newMessage and stamp.
    //   /// @todo update chat room `chat/rooms/otherId/myId`. increase newMessage and stamp.

    chatRoomInfo = await Api.instance.getRoomInformation(roomId);

    // // fetch latest messages
    fetchMessages();

    // // Listening current room in my room list.
    // // This will be notify chat room listener when chat room title changes, or new users enter, etc.
    // if (_currentRoomSubscription != null) _currentRoomSubscription.cancel();
    // _currentRoomSubscription = Api.instance.myRoom(roomId).onValue.listen((Event event) {
    //   // If the user got a message from a chat room where the user is currently in,
    //   // then, set `newMessages` to 0.
    //   final data = ChatRoomInfo.fromSnapshot(event.snapshot);
    //   if (data.newMessages > 0 && data.createdAt != null) {
    //     Api.instance.myRoom(roomId).update({'newMessages': 0});
    //   }
    // });
  }

  // /// Notify chat room listener to re-render the screen.
  _notify() {
    if (_render != null) _render();
  }

  /// Fetch previous messages
  fetchMessages() {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;

    page++;
    if (page == 1) {
      Api.instance.myRoom(roomId).set({'newMessages': 0});
    }

    /// Get messages for the chat room
    Query q = Api.instance.chatMessagesRef(roomId).orderByChild('createdAt').limitToLast(_limit);

    if (messages.isNotEmpty) {
      q = q.startAt([messages.first['createdAt']]);
    }

    // q.once().then((value) {
    //   print(value);
    // });

    _chatRoomSubscription = q.onValue.listen((Event event) {
      // print('fetchMessage() -> done: _page: $_page');
      // Block loading previous messages for some time.

      loading = false;
      Timer(Duration(milliseconds: _throttle), () => _throttling = false);

      print(event.snapshot);
      event.snapshot.value.forEach((key, data) {
        final message = data;

        message['id'] = key;

        messages.add(message);

        // print(message['text'] ?? '');
        print(message['createdAt']);
        // // print('type: ${documentChange.type}. ${message['text']}');

        // /// 새로 채팅을 하거나, 이전 글을 가져 올 때, 새 채팅(생성)뿐만 아니라, 이전 채팅 글을 가져올 때에도 added 이벤트 발생.
        // if (documentChange.type == DocumentChangeType.added) {
        //   // Two events will be fired on the sender's device.
        //   // First event has null of FieldValue.serverTimestamp()
        //   // Only one event will be fired on other user's devices.
        // if (message['createdAt'] == null) {
        //   messages.add(message);
        // }

        //   /// if it's new message, add at bottom.
        //   else if (messages.length > 0 &&
        //       messages[0]['createdAt'] != null &&
        //       message['createdAt'].microsecondsSinceEpoch >
        //           messages[0]['createdAt'].microsecondsSinceEpoch) {
        //     messages.add(message);
        //   } else {
        //     // if it's old message, add on top.
        //     messages.insert(0, message);
        //   }

        //   // if it is loading old messages
        //   // and if it has less messages than the limit
        //   // check if it is the very first message.
        //   if (message['createdAt'] != null) {
        //     if (snapshot.docs.length < _limit) {
        //       if (message['text'] == ChatProtocol.roomCreated) {
        //         noMoreMessage = true;
        //         // print('-----> noMoreMessage: $noMoreMessage');
        //       }
        //     }
        //   }
        // } else if (documentChange.type == DocumentChangeType.modified) {
        //   final int i = messages.indexWhere((r) => r['id'] == message['id']);
        //   if (i > -1) {
        //     messages[i] = message;
        //   }
        // } else if (documentChange.type == DocumentChangeType.removed) {
        //   final int i = messages.indexWhere((r) => r['id'] == message['id']);
        //   if (i > -1) {
        //     messages.removeAt(i);
        //   }
        // } else {
        //   assert(false, 'This is error');
        // }
      });
      _notify();
    });
  }

  unsubscribe() {
    _chatRoomSubscription.cancel();
    _currentRoomSubscription.cancel();
  }

  /// Send chat message to the users in the room
  ///
  /// [displayName] is the name that the sender will use. The default is
  /// `ff.user.displayName`.
  ///
  /// [photoURL] is the sender's photo url. Default is `ff.user.photoURL`.
  ///
  /// [type] is the type of the message. It can be `image` or `text` if string only.
  Future<Map<String, dynamic>> sendMessage({
    @required String text,
    Map<String, dynamic> extra,
    String url,
    String urlType,
  }) async {
    // if (displayName == null || displayName.trim() == '') {
    //   throw CHAT_DISPLAY_NAME_IS_EMPTY;
    // }

    Map<String, dynamic> message = {
      'senderUid': id,
      'text': text,
      'createdAt': ServerValue.timestamp,
      if (extra != null) ...extra,
    };

    await Api.instance.chatMessagesRef(roomId).push().set(message);
    await Api.instance
        .userRoomRef(otherUser.md5, roomId)
        .child('newMessages')
        .set(ServerValue.increment(1));

    // TODO: Sending notification should be handled outside of firechat.
    // await __ff.sendNotification(
    //   '$displayName send you message.',
    //   text,
    //   id: id,
    //   screen: 'chatRoom',
    //   topic: topic,
    // );
    return message;
  }

  text(Map<String, dynamic> message) {
    String text = message['text'] ?? '';
    if (text == ChatProtocol.roomCreated) {
      text = 'Chat room created. ';
    }

    /// Display `no more messages` only when user scrolled up to see more messages.
    else if (page > 1 && noMoreMessage) {
      text = 'No more messages. ';
    } else if (text == ChatProtocol.enter) {
      // print(message);
      text = "${message['senderDisplayName']} invited ${message['newUsers']}";
    }
    return text;
  }
}
