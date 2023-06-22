import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt_client/api/conversationDBApi.dart';
import 'package:mqtt_client/pojo/conversation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:typed_data/src/typed_buffer.dart';

import '../../api/messageDBApi.dart';
import '../../pojo/message.dart';

class MessagePage extends StatefulWidget {
  // 会话id
  final int conversationId;
  // mqtt对象
  final MqttClient mqttClient;

  const MessagePage({super.key, required this.conversationId, required this.mqttClient});

  @override
  State<StatefulWidget> createState() {
    return MessagePageState();
  }
}

class MessagePageState extends State<MessagePage> {

  final TextEditingController _messageController = TextEditingController();
  late Conversation _conversation;
  String _publishedTopic = "";
  String _subscribedTopic = "";
  List<Message> _messageList = [];

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != 0) {
      queryMessageList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('消息列表'),
            actions: [
              IconButton(
                onPressed: () {  },
                icon: const Icon(Icons.settings),
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                color: Colors.amber,
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text("已连接"),
                ),
              ),
            )
        ),
        body: mainBody()
    );
  }

  Widget mainBody() {
    // https://www.jianshu.com/p/72754a08b423
    AutoScrollController controller = AutoScrollController();

    return Column(
      children: [
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            reverse: true,
            controller: controller,
            itemCount: _messageList.length,
            itemBuilder: (BuildContext context, int index) {
              Message message = _messageList[index];
              bool onLeft = message.type == 2;
              return Container(
                  // height: 50,
                  // color: Colors.amber[colorCodes[index]],
                  child: onLeft ? receiverWidget(message) : publisherWidget(message));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              height: 10,
              // 透明的灰色
              color: Color(0x00d9d9d9),
            ),
          ),
        ),
        const Divider(height: 1.0),
        Container(
            // height: 60,
            // width: MediaQuery.of(context).size.width,
            // color: Theme.of(context).colorScheme.inversePrimary,
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: sendMessageBoxWidget()
        ),
      ],
    );
  }

  Widget receiverWidget(Message message) {
    return Row(
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(
                '收',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Container(
              width: 0,
              height: 0,
              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              decoration: const BoxDecoration(
                border: Border(
                  // 四个值 top right bottom left
                  bottom: BorderSide(
                      color: Colors.transparent, // 朝上; 其他的全部透明transparent或者不设置
                      width: 10,
                      style: BorderStyle.solid),
                  right: BorderSide(
                      color: Colors.transparent, // 朝左;  把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                  left: BorderSide(
                      color: Colors.black45, // 朝右；把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                  top: BorderSide(
                      color: Colors.transparent, // 朝下;  把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                ),
              ),
            ),
            Container(
                width: 240,
                constraints: const BoxConstraints(
                  minHeight: 40,
                ),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.black45),
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                    message.content,
                    softWrap: true,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    )
                )
            )
          ],
        ),
        const Expanded(
            child: SizedBox(
          width: 20,
        )),
      ],
    );
  }

  Widget publisherWidget(Message message) {
    return Row(
      children: [
        const Expanded(child: SizedBox(width: 20)),
        Row(
          children: [
            Container(
                width: 240,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.green),
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                    message.content,
                    softWrap: true,
                    style: const TextStyle(color: Colors.black))),
            Container(
              width: 0,
              height: 0,
              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              decoration: const BoxDecoration(
                border: Border(
                  // 四个值 top right bottom left
                  bottom: BorderSide(
                      color: Colors.transparent, // 朝上; 其他的全部透明transparent或者不设置
                      width: 10,
                      style: BorderStyle.solid),
                  right: BorderSide(
                      color: Colors.transparent, // 朝左;  把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                  left: BorderSide(
                      color: Colors.black45, // 朝右；把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                  top: BorderSide(
                      color: Colors.transparent, // 朝下;  把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                ),
              ),
            ),
            const CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: Text(
                '发',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget sendMessageBoxWidget() {
    if (_publishedTopic.isEmpty) {
      return Container();
    }

    return TextFormField(
        autofocus: false,
        keyboardType: TextInputType.text,
        controller: _messageController,
        decoration: InputDecoration(
            // labelText: '消息',
            labelStyle: const TextStyle(
              fontSize: 20,
            ),
            hintText: '发送消息',
            //不需要输入框下划线
            border: InputBorder.none,
            //右边图标设置
            suffixIcon: IconButton(
                onPressed: () {
                  String text = _messageController.text;
                  if (text.isNotEmpty) {
                    print('send message：$text');
                    Uint8Buffer dataBuffer = Uint8Buffer();
                    dataBuffer.addAll(const Utf8Encoder().convert(text));
                    try {
                      int count = widget.mqttClient.publishMessage(_conversation.publishedTopic.toString(), MqttQos.atLeastOnce, dataBuffer);
                      if (count > 0) {
                        _messageController.clear();
                        Map<String, dynamic> map = {
                          'conversation_id': _conversation.id,
                          'type': 1,
                          'topic': _conversation.publishedTopic,
                          'content': text,
                          'created_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        };
                        insertMessage(map);

                        queryMessageList();
                      }
                    } on Exception catch (e) {

                      debugPrint(e.toString() + _conversation.publishedTopic.toString());
                    }
                  }
                },
                icon: const Icon(Icons.send),
            )
        )
    );
  }

  void queryMessageList() {
    getConversationById(id: widget.conversationId).then((conversation) {
      if (conversation != null) {
        setState(() {
          _conversation = conversation;
          _publishedTopic = conversation.publishedTopic.toString();
          _subscribedTopic = conversation.subscribedTopic.toString();
        });
      }
    });

    getMessages(conversationId: widget.conversationId).then((messages) {
      setState(() {
        _messageList = messages;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
