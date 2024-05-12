

import 'package:mqtt_client/router/myRoute.dart';
import 'package:mqtt_client/views/conversation_manage/message_page.dart';
import 'package:mqtt_client/views/empty_page.dart';
import 'package:mqtt_client/views/home_page.dart';

import 'package:mqtt_client/views/add_client.dart';
import 'package:mqtt_client/views/conversation_manage/index.dart';


Map<String, Function> constantRoutes = {
  "HomePage": (context, arguments) => MyRoute(
      name: "HomePage",
      widget:  const HomePage(),
      method: "newPagePush",
      context: context,
      arguments: arguments,
  ),
  "EmptyPage": (context, arguments) => MyRoute(
      name: "EmptyPage",
      widget: const EmptyPage(),
      method: "endPanelPush",
      context: context,
      arguments: arguments
  ),
  "ClientAdd": (context, arguments) => MyRoute(
      name: "ClientAdd",
      widget: const ClientAddFul(),
      method: "endPanelPush",
      context: context,
      arguments: arguments
  ),
  "ConversationManagePage": (context, arguments) => MyRoute(
      name: "ConversationManagePage",
      widget: const ConversationManage(),
      method: "newPagePush",
      context: context,
      arguments: arguments
  ),
  "ConversationMessagePage": (context, arguments) => MyRoute(
      name: "ConversationMessage",
      widget: const MessagePage(),
      method: "endPanelPush",
      context: context,
      arguments: arguments
  )
};