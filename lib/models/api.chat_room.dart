part of '../firelamp.dart';

/// Chat room message list helper class.
class ApiChatRoom extends ChatHelper {
  /// [render] will be called to notify chat room listener to re-render the screen.
  ///
  /// For one chat message sending,
  /// - [render] will be invoked 2 times on message sender's device due to offline support.
  /// - [render] will be invoked 1 times on receiver's device.
  ///
  /// [globalRoomChange] will be invoked when global chat room changes.
  ApiChatRoom({
    Function render,
  }) : _render = render {
    /// If it renders too much, reduce it.
    _notifySubjectSubscription =
        _notifySubject.debounceTime(Duration(milliseconds: 50)).listen((x) {
      _render();
    });
  }

  ApiUser otherUser;

  /// [otherUserUid] is the other user's document key that the login user is talking to.
  String get otherUserUid => otherUser.md5;

  /// Room id
  String roomId;

  /// push notification topic name
  String get topic => 'notifyChat_${this.roomId}';

  /// When user scrolls to top to view previous messages, the app fires the scroll event
  /// too much, so it fetches too many batches(pageNos) at one time.
  /// [_throttle] reduces the scroll event to relax the fetch racing.
  /// [_throttle] is working together with [_throttling]
  /// 1500ms is recommended.
  int _throttle = 1500;

  bool _throttling = false;

  ///
  Function _render;

  StreamSubscription _childAddedSubscription;
  StreamSubscription _childChangedSubscription;
  StreamSubscription _childRemovedSubscription;
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
  ApiRoom chatRoomInfo;

  /// Chat room properties
  String get id => chatRoomInfo?.roomId;
  String get title => chatRoomInfo?.title;
  List<String> get users => chatRoomInfo?.users;
  Timestamped get createdAt => chatRoomInfo.createdAt;

  PublishSubject _notifySubject = PublishSubject();
  StreamSubscription _notifySubjectSubscription;

  /// Enter chat room
  Future<void> enter(String userId) async {
    otherUser = await Api.instance.otherUserProfile(userId);

    // print('otherUser: $otherUser');

    roomId = otherUser.data['roomId'];

    ///create `chat/rooms/myId/roomId` if not exists.
    ///create `chat/rooms/otherId/roomId` if not exists.
    final value = await myRoom(roomId);
    if (value == null || value.createdAt == null) {
      await roomsRef(myUid, roomId: roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'userId': otherUser.id,
        'displayName': otherUser.nickname,
        'profilePhotoUrl': otherUser.profilePhotoUrl,
      });
      await roomsRef(otherUserUid, roomId: roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'userId': Api.instance.id,
        'displayName': Api.instance.nickname,
        'profilePhotoUrl': Api.instance.profilePhotoUrl,
      });

      /// send message to `chat/message/roomId` with protocol roomCreated
      ///   await sendMessage(text: ChatProtocol.roomCreated, displayName: loginUserId);
      await messagesRef(roomId).push().set({
        'createdAt': ServerValue.timestamp,
        'userId': Api.instance.id,
        'protocol': ChatProtocol.roomCreated
      });
    }

    chatRoomInfo = await myRoom(roomId);

    // fetch latest messages
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

  leave() {
    otherUser = null;
  }

  // /// Notify chat room listener to re-render the screen.
  /// Render may happen too much. Reduce it.
  _notify() {
    if (_render != null) {
      _notifySubject.add(null);
    }
  }

  /// Fetch previous messages
  fetchMessages() async {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;

    pageNo++;
    if (pageNo == 1) {
      myRoomRef(roomId).update({'newMessages': 0});
    }

    /// Get messages for the chat room
    Query q = messagesRef(roomId).orderByKey();

    if (pageNo > 1) {
      print('endAt: ${messages[0]}');
      q = q.endAt(messages.first['id']);
    }

    q = q.limitToLast(_limit);

    _childChangedSubscription = q.onChildChanged.listen((Event event) {
      // @todo update message
    });
    _childRemovedSubscription = q.onChildRemoved.listen((Event event) {
      // @todo delete message
    });

    _childAddedSubscription = q.onChildAdded.listen((Event event) {
      loading = false;
      Timer(Duration(milliseconds: _throttle), () => _throttling = false);

      // print(event.snapshot.value);
      final message = event.snapshot.value;
      message['id'] = event.snapshot.key;

      /// On first page, just add chats at the bottom.
      if (pageNo == 1) {
        messages.add(message);
      } else if (message['createdAt'] >= messages.last['createdAt']) {
        /// On new chat, just add at bottom.
        messages.add(message);
      } else {
        /// On previous chat, add chat messages on top, but with the order of chat messages.
        for (int i = 0; i < messages.length; i++) {
          if (message['createdAt'] <= messages[i]['createdAt']) {
            messages.insert(i, message);
            break;
          }
        }
      }

      // if it is loading old messages
      // check if it is the very first message.
      if (message['createdAt'] != null) {
        if (message['protocol'] == ChatProtocol.roomCreated) {
          noMoreMessage = true;
          print('-----> noMoreMessage: $noMoreMessage');
        }
      }

      _notify();
    });
  }

  unsubscribe() {
    _childAddedSubscription.cancel();
    _childChangedSubscription.cancel();
    _childRemovedSubscription.cancel();
    _currentRoomSubscription.cancel();
    _notifySubjectSubscription.cancel();
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
      'userId': Api.instance.id,
      'text': text,
      'createdAt': ServerValue.timestamp,
      if (extra != null) ...extra,
    };

    await messagesRef(roomId).push().set(message);
    await roomsRef(otherUserUid, roomId: roomId).update({
      'newMessages': ServerValue.increment(1),
      'updatedAt': ServerValue.timestamp,
    });

    // ///Sending pushnotification after updating the chat
    // Api.instance.sendMessageToUsers(
    //   users: [otherUser.id],
    //   title: 'chat message',
    //   subscription: "notifyChat_" + Api.instance.id,
    //   body: text,
    //   data: {'type': 'chat'},
    // );
    return message;
  }
}
