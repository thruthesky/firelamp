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
    ///
    /// `onChildAdded` event fires to often.
    _notifySubjectSubscription =
        _notifySubject.debounceTime(Duration(milliseconds: 50)).listen((x) {
      /// Scroll down for new message(s)
      ///
      /// For image, it will be scrolled down again(one more time) after image had completely loaded.
      if (messages.isNotEmpty) {
        if (pageNo == 1) {
          scrollToBottom(ms: 10);
        } else if (atBottom) {
          scrollToBottom();
        }
      }
      _render();
    });
  }

  /// Other user
  ApiUser otherUser;

  /// [otherUserId] is the other user profile id
  String otherUserId;

  /// [roomId] is the combination of the User A md5 and user B md5 which is return when you get the other user profile.
  String get roomId {
    if (int.parse(Api.instance.id) < int.parse(otherUserId)) {
      return "${Api.instance.id}-$otherUserId";
    } else {
      return "$otherUserId-${Api.instance.id}";
    }
  }

  /// push notification topic name
  String get topic => 'notifyChat_${this.roomId}';
  bool get subscribed {
    return Api.instance.user.data[topic] == null || Api.instance.user.data[topic] == 'Y';
  }

  set subscribed(bool v) {
    Api.instance.user?.data[topic] = v ? 'Y' : 'N';
  }

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
  bool loading = true;

  /// The [lastImage] is the last image of the chat room.
  ///
  /// Flutter rebuilds the screen whenever list(or any scroll) view shows images into screen.
  /// And same images will be rendered over again.
  /// If you want to scroll down(to the bottom) for new image only, then this might be a solution.
  /// Whenever images are rendered on screen, scroll down only if the image is the last image.
  String lastImage = '';

  /// Global room info (of current room)
  /// Use this to dipplay title or other information about the room.
  /// When `/chat/global/room-list/{roomId}` changes, it will be updated and calls render handler.
  ApiChatUserRoom chatRoomInfo;

  PublishSubject _notifySubject = PublishSubject();
  StreamSubscription _notifySubjectSubscription;

  /// [textController] is the same textcontroller that was use in bottom_actions widget
  /// this can be use when you want to replace the text on bottom_action like when you want to edit
  final textController = TextEditingController();

  final scrollController = ScrollController();

  /// When keyboard(keypad) is open, the app needs to adjust the scroll.
  final keyboardVisibilityController = KeyboardVisibilityController();
  StreamSubscription keyboardSubscription;

  /// Scrolls down to the bottom when,
  /// * chat room is loaded (only one time.)
  /// * when I chat,
  /// * when new chat is coming and the page is scrolled near to bottom. Logically it should not scroll down when the page is scrolled far from the bottom.
  /// * when keyboard is open and the page scroll is near to bottom. Locally it should not scroll down when the user is reading message that is far from the bottom.
  scrollToBottom({int ms = 100}) {
    /// This is needed to safely scroll to bottom after chat messages has been added.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients)
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: ms), curve: Curves.ease);
    });
  }

  ApiChatMessage isMessageEdit;

  /// Enter chat room
  Future<void> enter(String userId) async {
    otherUserId = userId;
    otherUser = await Api.instance.otherUserProfile(userId);

    /// get room information
    ApiChatUserRoom value = await myRoom(roomId);

    /// If the room does not exists, create one.
    if (value == null || value.createdAt == null) {
      /// Create my room
      ///
      /// Create `chat/rooms/myId/roomId` if not exists.
      /// LoggedIn User copy of Other User Room Information
      await roomsRef(myId, roomId: roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'userId': otherUser.id,
        'displayName': otherUser.nickname,
        'profilePhotoUrl': otherUser.profilePhotoUrl,
      });

      /// Create the other room
      ///
      /// Create `chat/rooms/otherUid/roomId` if not exists.
      /// Other user copy of LoggedIn User Room Information
      await roomsRef(otherUserId, roomId: roomId).set({
        'createdAt': ServerValue.timestamp,
        'newMessages': 0,
        'userId': Api.instance.id,
        'displayName': Api.instance.nickname,
        'profilePhotoUrl': Api.instance.profilePhotoUrl,
      });

      /// Save the first message on message document.
      ///
      /// send message to `chat/message/roomId` with protocol roomCreated
      /// await sendMessage(text: ChatProtocol.roomCreated, displayName: loginUserId);
      await messagesRef(roomId).push().set({
        'createdAt': ServerValue.timestamp,
        'userId': Api.instance.id,
        'protocol': ChatProtocol.roomCreated
      });
    } else {
      /// Update latest name and photo of mine.
      ///
      /// Update your copy of other User and update the Room Information
      await roomsRef(myId, roomId: roomId).update({
        'displayName': otherUser.nickname,
        'profilePhotoUrl': otherUser.profilePhotoUrl,
      });
    }

    // Get room info
    chatRoomInfo = await myRoom(roomId);

    // fetch latest messages
    fetchMessages();

    // Listening current room in my room list.
    // This will be notify chat room listener when chat room title changes, or new users enter, etc.
    if (_currentRoomSubscription != null) _currentRoomSubscription.cancel();
    _currentRoomSubscription =
        roomsRef(Api.instance.id, roomId: roomId).onValue.listen((Event event) {
      // If the user got a message from a chat room where the user is currently in,
      // then, set `newMessages` to 0.
      final data = ApiChatUserRoom.fromSnapshot(event.snapshot);
      if (data.newMessages != null && data.newMessages > 0 && data.createdAt != null) {
        roomsRef(Api.instance.id, roomId: roomId).update({'newMessages': 0});
      }
    });

    // fetch previous chat when user scrolls up
    scrollController.addListener(() {
      if (scrollUp && atTop) {
        Api.instance.chat.fetchMessages();
      }
    });

    // scroll to bottom only if needed when user open/hide keyboard.
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible && atBottom) {
        scrollToBottom(ms: 10);
      }
    });
  }

  /// Notify chat room listener to re-render the screen.
  /// Render may happen too much. Reduce it.
  notify() {
    if (_render != null) {
      _notifySubject.add(null);
    }
  }

  /// Fetch previous messages
  fetchMessages() async {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;
    // notify();

    pageNo++;
    if (pageNo == 1) {
      myRoomRef(roomId).update({'newMessages': 0});
    }

    /// Get messages for the chat room
    // Query q = messagesRef(roomId).orderByKey();

    Query q = messagesRef(roomId).orderByChild('createdAt');

    if (pageNo > 1) {
      // q = q.endAt(messages.first['id']);
      q = q.endAt(messages.first['createdAt']);
    }

    q = q.limitToLast(_limit);

    _childChangedSubscription = q.onChildChanged.listen((Event event) {
      print('onChildChanged');
      int i = messages.indexWhere((m) => m['id'] == event.snapshot.key);
      messages[i]['text'] = event.snapshot.value['text'];
      notify();
    });
    _childRemovedSubscription = q.onChildRemoved.listen((Event event) {
      print('onChildRemoved;');
      messages.removeWhere((m) => m['id'] == event.snapshot.key);
      notify();
    });

    _childAddedSubscription = q.onChildAdded.listen((Event event) {
      // print('onChildAdded');
      loading = false;
      Timer(Duration(milliseconds: _throttle), () => _throttling = false);

      // print(event.snapshot.value);
      final message = event.snapshot.value;
      message['id'] = event.snapshot.key;

      /// On first page, just add chats at the bottom.
      if (messages.length > 0 && message['createdAt'] < messages.first['createdAt']) {
        messages.insert(0, message);
      } else if (pageNo == 1) {
        addMessageAtBottom(message);
      } else if (message['createdAt'] >= messages.last['createdAt']) {
        /// On new chat, just add at bottom.
        addMessageAtBottom(message);
      } else {
        /// On previous chat, add chat messages on top, but with the order of chat messages.
        insertMessageAtFront(message);
      }

      // if it is loading old messages
      // check if it is the very first message.
      if (message['createdAt'] != null) {
        if (message['protocol'] == ChatProtocol.roomCreated) {
          noMoreMessage = true;
          // print('-----> noMoreMessage: $noMoreMessage');
        }
      }
      notify();
    });
  }

  addMessageAtBottom(dynamic message) {
    messages.add(message);
    if (isImageUrl(message['text'])) lastImage = message['text'];
  }

  insertMessageAtFront(dynamic message) {
    for (int i = 0; i < messages.length; i++) {
      if (message['createdAt'] <= messages[i]['createdAt']) {
        messages.insert(i, message);
        break;
      }
    }
  }

  deleteMessage(ApiChatMessage message) {
    messageRef(roomId, message.id).remove();
  }

  editMessage(ApiChatMessage message) {
    textController.text = message.text;
    isMessageEdit = message;
    notify();
  }

  bool isMessageOnEdit(ApiChatMessage message) {
    if (isMessageEdit == null) return false;
    if (!message.isMine) return false;
    return message.id == isMessageEdit.id;
  }

  cancelEdit() {
    textController.text = '';
    isMessageEdit = null;
    notify();
  }

  unsubscribe() {
    if (_childAddedSubscription != null) _childAddedSubscription.cancel();
    if (_childChangedSubscription != null) _childChangedSubscription.cancel();
    if (_childRemovedSubscription != null) _childRemovedSubscription.cancel();
    if (_currentRoomSubscription != null) _currentRoomSubscription.cancel();
    if (_notifySubjectSubscription != null) _notifySubjectSubscription.cancel();
    if (keyboardSubscription != null) keyboardSubscription.cancel();
    otherUser = null;
  }

  /// Send chat message to the users in the room
  Future<Map<String, dynamic>> sendMessage({
    @required String text,
    Map<String, dynamic> extra,
  }) async {
    Map<String, dynamic> message = {
      'userId': Api.instance.id,
      'text': text,
      if (extra != null) ...extra,
    };

    /// New Message
    if (isMessageEdit == null) {
      message['createdAt'] = ServerValue.timestamp;
      await messagesRef(roomId).push().set(message);

      await roomsRef(otherUserId, roomId: roomId).update({
        'newMessages': ServerValue.increment(1),
        'updatedAt': ServerValue.timestamp,
        'text': text,
      });
    }

    /// Edit Message
    else {
      message['updatedAt'] = ServerValue.timestamp;
      await messageRef(roomId, isMessageEdit.id).update(message);
      isMessageEdit = null;
    }
    return message;
  }

  Future<dynamic> sendChatPushMessage(String body) {
    return Api.instance.sendMessageToUsers(
      users: [otherUser.id],
      title: 'chat message',
      subscription: topic,
      body: body,
      data: {
        'type': 'chat',
      },
    );
  }

  bool get atBottom {
    return scrollController.offset > (scrollController.position.maxScrollExtent - 640);
  }

  bool get atTop {
    return scrollController.position.pixels < 200;
  }

  bool get scrollUp {
    return scrollController.position.userScrollDirection == ScrollDirection.forward;
  }

  bool get scrollDown {
    return scrollController.position.userScrollDirection == ScrollDirection.reverse;
  }
}
