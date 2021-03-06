part of 'firelamp.dart';

const String ERROR_EMPTY_SESSION_ID = 'ERROR_EMPTY_SESSION_ID';

const String ERROR_IMAGE_NOT_SELECTED = 'ERROR_IMAGE_NOT_SELECTED';
const String ERROR_EMPTY_TOKENS = 'ERROR_EMPTY_TOKENS';

/// Error codes
const String ERROR_EMPTY_RESPONSE = 'ERROR_EMPTY_RESPONSE';

const String ERROR_ALREADY_ADDED_AS_FRIEND = 'error_already_added_as_friend';
const String ERROR_USER_NOT_FOUND_BY_THAT_EMAIL = 'error_user_not_found_by_that_email';
const String ERROR_NO_RELATIONSHIP = 'error_no_relationship';

/// Defines
const String FIREBASE_UID = 'firebaseUid';

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
