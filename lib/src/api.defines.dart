import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

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

class Space {
  // static const double xxs = 4;
  // static const double xs = 8;
  // static const double xsm = 12;
  // static const double sm = 16;
  // static const double md = 24;
  // static const double lg = 32;
  // static const double xl = 40;
  // static const double xxl = 56;
  static const double xxs = 4;
  static const double xs = 8;
  static const double xsm = 12;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 40;
  static const double xxl = 56;

  static double get forumViewPadding => 10.0;
}

const stylePostTitle = TextStyle(
  fontSize: 20,
  color: Colors.blueGrey,
  fontWeight: FontWeight.w400,
  // fontFamily: '',
);

const styleHintText = TextStyle(fontSize: Space.xsm, color: Colors.grey);
