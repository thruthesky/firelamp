library firelamp;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firelamp/models/api.post.user.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart' as Prefix;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:age/age.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'api.defines.dart';
part 'api.functions.dart';
part 'api.controller.dart';
part 'api.shopping-mall.controller.dart';

part 'models/api.comment.dart';
part 'models/api.file.dart';
part 'models/api.post.dart';
part 'models/api.category.dart';
part 'models/api.user.dart';
part 'models/api.forum.dart';
