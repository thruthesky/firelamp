library firelamp;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as Prefix;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:age/age.dart';
import 'package:path/path.dart' as p;

part 'api.defines.dart';
part 'api.functions.dart';
part 'api.controller.dart';

part 'models/api.comment.dart';
part 'models/api.file.dart';
part 'models/api.post.dart';
part 'models/api.user.dart';
part 'models/api.forum.dart';
part 'models/api.chat_helper.dart';
part 'models/api.chat_room.dart';
part 'models/api.chat_room_list.dart';
part 'models/api.chat.model.dart';
