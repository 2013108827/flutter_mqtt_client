

import 'package:flutter/cupertino.dart';

class MyRoute {

  late String name;

  late Widget widget;

  late String method;

  late BuildContext context;

  late Object arguments;

  MyRoute ({
    required this.name,
    required this.widget,
    required this.method,
    required this.context,
    required this.arguments
  });

}