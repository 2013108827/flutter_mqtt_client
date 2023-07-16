import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt_client/api/conversationDBApi.dart';
import 'package:mqtt_client/pojo/conversation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../api/messageDBApi.dart';
import '../../pojo/message.dart';

class MessagePage extends StatefulWidget {
  // 会话id
  final int conversationId;
  // mqtt对象
  final MqttClient mqttClient;

  const MessagePage(
      {super.key, required this.conversationId, required this.mqttClient});

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
  final MqttPayloadBuilder payloadBuilder = MqttPayloadBuilder();

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
      // 弹出键盘时，阻止页面自动上划
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('消息列表'),
          actions: [
            IconButton(
              onPressed: () {
                showDeleteMessagesDialog(context);
              },
              icon: const Icon(Icons.delete_forever),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Container(
              height: 40,
              color: Colors.amber[400],
              width: MediaQuery.of(context).size.width,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "订阅",
                        style: TextStyle(color: Colors.pink),
                      ),
                      Text(_subscribedTopic)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("发布", style: TextStyle(color: Colors.pink)),
                      Text(_publishedTopic)
                    ],
                  )
                ],
              ),
            ),
          )),
      body: mainBody(),
      floatingActionButton: _publishedTopic.isEmpty ? null : FloatingActionButton(
        onPressed: () {
          showSendMessageBoxWidget(context);
        },
        child: const Icon(Icons.send),
      ),
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
                  child: onLeft
                      ? receiverWidget(message)
                      : publisherWidget(message));
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
        // Container(
        //     // height: 60,
        //     // width: MediaQuery.of(context).size.width,
        //     // color: Theme.of(context).colorScheme.inversePrimary,
        //     padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        //     decoration: BoxDecoration(
        //       color: Theme.of(context).cardColor,
        //     ),
        //     child: sendMessageBoxWidget()
        // ),
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
                child: SelectableText(message.content,
                    style: const TextStyle(color: Colors.white, fontSize: 20)))
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
                constraints: const BoxConstraints(
                  minHeight: 40,
                ),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.green),
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: SelectableText(message.content,
                    style: const TextStyle(color: Colors.black, fontSize: 20))),
            Container(
              width: 0,
              height: 0,
              margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              decoration: const BoxDecoration(
                border: Border(
                  // 四个值 top right bottom left
                  bottom: BorderSide(
                      color: Colors.transparent, // 朝上; 其他的全部透明transparent或者不设置
                      width: 10,
                      style: BorderStyle.solid),
                  right: BorderSide(
                      color: Colors.green, // 朝左;  把颜色改为目标色就可以了；其他的透明
                      width: 10,
                      style: BorderStyle.solid),
                  left: BorderSide(
                      color: Colors.transparent, // 朝右；把颜色改为目标色就可以了；其他的透明
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

    return Row(
      children: [
        // SizedBox(
        //   width: 87,
        //   child:  DropdownButtonFormField(
        //       value: _messageType,
        //       items: const [
        //         DropdownMenuItem(value: 'text', child: Text('PlainText')),
        //         DropdownMenuItem(value: 'json', child: Text('JSON')),
        //       ],
        //       onChanged: (value) {
        //         if (value != null) {
        //           setState(() {
        //             _messageType = value;
        //           });
        //         }
        //       },
        //       decoration: const InputDecoration(
        //         //不需要输入框下划线
        //         border: InputBorder.none,
        //       ),
        //   ),
        // ),
        Expanded(
            child: TextFormField(
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
                    // 左边图标设置
                    // prefix: ,
                    //右边图标设置
                    suffixIcon: IconButton(
                      onPressed: () {
                        String text = _messageController.text;
                        if (text.isNotEmpty) {
                          debugPrint('send message：$text');
                          // Uint8Buffer dataBuffer = Uint8Buffer();
                          // dataBuffer.addAll(const Utf8Encoder().convert(text));
                          try {
                            payloadBuilder.addUTF8String(text);
                            int count = widget.mqttClient.publishMessage(
                                _conversation.publishedTopic.toString(),
                                MqttQos.atLeastOnce,
                                payloadBuilder.payload!);
                            // 清空payload
                            payloadBuilder.clear();
                            if (count > 0) {
                              _messageController.clear();
                              Map<String, dynamic> map = {
                                'conversation_id': _conversation.id,
                                'type': 1,
                                'topic': _conversation.publishedTopic,
                                'content': text,
                                'created_time':
                                    DateTime.now().millisecondsSinceEpoch ~/
                                        1000,
                              };
                              insertMessage(map);

                              queryMessageList();
                            }
                          } on Exception catch (e) {
                            debugPrint(e.toString() +
                                _conversation.publishedTopic.toString());
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                    ))))
      ],
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

  void showSendMessageBoxWidget(BuildContext context) {
    String payloadType = "PlainText";
    MqttQos qos = MqttQos.atLeastOnce;

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Column(
              children: [
                // Material(
                //   child: DropdownButtonFormField(
                //       value: payloadType,
                //       isExpanded: true,
                //       decoration: const InputDecoration(
                //           border: OutlineInputBorder(), labelText: 'payload类型'),
                //       items: const [
                //         DropdownMenuItem(
                //             value: 'PlainText', child: Text('PlainText')),
                //         DropdownMenuItem(value: 'JSON', child: Text('JSON')),
                //         DropdownMenuItem(
                //             value: 'Base64', child: Text('Base64')),
                //         DropdownMenuItem(value: 'Hex', child: Text('Hex')),
                //       ],
                //       onChanged: (value) {}),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                Material(
                  child: DropdownButtonFormField(
                      value: qos,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'QoS'),
                      items: const [
                        DropdownMenuItem(value: MqttQos.atMostOnce, child: Text('0 至多一次',)),
                        DropdownMenuItem(value: MqttQos.atLeastOnce, child: Text('1 至少一次')),
                        DropdownMenuItem(value: MqttQos.exactlyOnce, child: Text('2 仅一次')),
                      ],
                      onChanged: (value) {}),
                ),
                const SizedBox(
                  height: 10,
                ),
                Material(
                    child: TextFormField(
                        autofocus: false,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'payload',
                          labelStyle: TextStyle(
                            fontSize: 20,
                          ),
                          hintText: '消息内容',
                          //不需要输入框下划线
                          // border: InputBorder.none,
                          border: OutlineInputBorder(),
                        ))),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text(
                  '发送',
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  String text = _messageController.text;
                  if (text.isNotEmpty) {
                    debugPrint('send message：$text');
                    // Uint8Buffer dataBuffer = Uint8Buffer();
                    // dataBuffer.addAll(const Utf8Encoder().convert(text));
                    try {
                      payloadBuilder.addUTF8String(text);
                      int count = widget.mqttClient.publishMessage(
                          _conversation.publishedTopic.toString(),
                          qos,
                          payloadBuilder.payload!);
                      // 清空payload
                      payloadBuilder.clear();
                      if (count > 0) {
                        _messageController.clear();
                        Map<String, dynamic> map = {
                          'conversation_id': _conversation.id,
                          'type': 1,
                          'topic': _conversation.publishedTopic,
                          'content': text,
                          'created_time':
                              DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        };
                        insertMessage(map);

                        queryMessageList();
                      }
                    } on Exception catch (e) {
                      debugPrint(e.toString() +
                          _conversation.publishedTopic.toString());
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  void showDeleteMessagesDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
              '警告',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 25
            ),
          ),
          content: const Text(
            '该操作删除本会话下的所有的消息记录',
            style: TextStyle(
              fontSize: 17
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                debugPrint('删除所有的聊天记录');
                if (_messageList.isNotEmpty) {
                  for (Message message in _messageList) {
                    deleteMessage(message.id);
                  }
                  queryMessageList();
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
