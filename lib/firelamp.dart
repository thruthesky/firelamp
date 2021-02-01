library firelamp;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as Prefix;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:age/age.dart';

part 'api.functions.dart';
part 'api.controller.dart';

part 'models/api.comment.dart';
part 'models/api.file.dart';
part 'models/api.post.dart';
part 'models/api.user.dart';

final Api api = Api();
