export './loading_wrapper.dart';
export './base_height.dart';
export './dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

//Scaffold에 스낵바 만들기. Builder로 감싸주어야함.
showSnackBar(BuildContext context, String text) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(milliseconds: 1000),
    ),
  );
}

//로거 모듈
var log = Logger();
