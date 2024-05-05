

import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt_client/views/conversation_manage/message_page.dart';
import 'package:mqtt_client/views/home_page.dart';

import 'package:mqtt_client/views/add_client.dart';
import 'package:mqtt_client/views/conversation_manage/index.dart';

Map<String, Map> constantRoutes = {
  "HomePage": {
    "widget": (context) => const HomePage()
  },
  "ClientAdd": {
    "widget": (context, {arguments}) => ClientAddFul(arguments: arguments),
    "routeMethod": "endPanelPush"
  },
  "ConversationManage": {
    "widget": (context, {arguments}) => ConversationManage(arguments: arguments),
    "routeMethod": "newPagePush"
  },
  "ConversationMessage": {
    "widget": (context, int conversationId, MqttClient mqttClient) => MessagePage(conversationId: conversationId, mqttClient: mqttClient),
    "routeMethod": "endPanelPush"
  }
};