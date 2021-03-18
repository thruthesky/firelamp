part of 'firelamp.dart';

const String ERROR_EMPTY_SESSION_ID = 'ERROR_EMPTY_SESSION_ID';

const String ERROR_IMAGE_NOT_SELECTED = 'ERROR_IMAGE_NOT_SELECTED';
const String ERROR_EMPTY_TOKENS = 'ERROR_EMPTY_TOKENS';

/// todo put chat protocol into { protocol: ... }, not in { text: ... }
class ChatProtocol {
  static String enter = 'ChatProtocol.enter';
  static String add = 'ChatProtocol.add';
  static String leave = 'ChatProtocol.leave';
  static String kickout = 'ChatProtocol.kickout';
  static String block = 'ChatProtocol.block';
  static String roomCreated = 'ChatProtocol.roomCreated';
}

const String NEW_COMMENT_ON_MY_POST_OR_COMMENT = 'newCommentUserOption';

class NotificationOptions {
  static String notifyPost = 'notifyPost_';
  static String notifyComment = 'notifyComment_';

  static String post(String category) {
    return notifyPost + category;
  }

  static String comment(String category) {
    return notifyComment + category;
  }
}
