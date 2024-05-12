
import 'package:flutter/cupertino.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt_client/api/conversationDBApi.dart';
import 'package:mqtt_client/api/messageDBApi.dart';
import 'package:mqtt_client/pojo/conversation.dart';

import 'package:mqtt_client/pojo/message.dart';

class ConversationMessageProvider with ChangeNotifier {

  // late int conversationId;

  MqttClient? mqttClient;

  Conversation? conversation;

  List<Message> messageList = [];

  void inputMqttClient(MqttClient myMqttClient) {
    Future(() => mqttClient = myMqttClient).then((_) => notifyListeners());
  }

  void queryMessageList(int conversationId) {
     getMessages(conversationId: conversationId).then((value) {
       messageList = value;
       print("queryMessageList");
       notifyListeners();
     });
  }

  void queryMessageListAndConversation(int conversationId) {
    Future messagesFuture = getMessages(conversationId: conversationId).then((value) {
      messageList = value;
      print("queryMessageList");
    });

    Future conversationFuture = getConversationById(id: conversationId).then((value) {
      if (value != null) {
        print("queryConversation");
        conversation = value;
      }
    });
    Future.wait([messagesFuture, conversationFuture]).then((_) => notifyListeners());
  }

}