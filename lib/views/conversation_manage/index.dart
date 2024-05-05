import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:mqtt_client/api/messageDBApi.dart';
import 'package:mqtt_client/pojo/broker.dart';
import 'package:mqtt_client/views/conversation_manage/message_page.dart';

import '../../api/conversationDBApi.dart';
import '../../pojo/conversation.dart';
import '../../utils/DatabaseApiUtils.dart';

class ConversationManage extends StatefulWidget {

  static const routeName = 'ConversationManage';

  // 数据库id,没有时传0
  final Map arguments;

  const ConversationManage({super.key, required this.arguments});

  @override
  State<StatefulWidget> createState() {
    return ConversationManageState();
  }
}

class ConversationManageState extends State<ConversationManage> {
  // broker的数据库id
  int initBrokerId = 0;
  // broker别名
  String initBrokerAlias = "";

  List<Conversation> _conversationList = [];
  int _conversationListLength = 0;
  int _conversationId = 0;
  late Broker _broker;
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  late MqttServerClient _mqttClient;
  String _appBarSubTitle = "连接中";
  bool _connected = false;
  final GlobalKey<MessagePageState> _messagePageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.arguments["initBrokerId"] != null) {
      setState(() {
        initBrokerId = widget.arguments["initBrokerId"];
      });

    }
    if (widget.arguments["initBrokerAlias"] != null) {
      setState(() {
        initBrokerAlias = widget.arguments["initBrokerAlias"];
      });
    }

    if (initBrokerId != 0) {
      queryConversationList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('$initBrokerAlias-会话列表'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                color: Colors.amber,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(_appBarSubTitle),
                ),
              ),
            )),
        body: dataList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_connected) {
              debugPrint("添加会话");
              mySimpleDialog(context, '添加会话');
            }
          },
          tooltip: 'Increment',
          backgroundColor: _connected
              ? Theme.of(context).colorScheme.inversePrimary
              : Colors.grey,
          child: const Icon(Icons.add),
        ));
  }

  Widget dataList() {
    if (_conversationList.isEmpty) {
      return const Center(
        child: Text('暂无活跃会话'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _conversationList.length,
      itemBuilder: (BuildContext context, int index) {
        Conversation conversation = _conversationList[index];
        String title = (index + 1).toString();
        title +=
            ' - ${(conversation.publishedTopic!.isNotEmpty ? conversation.publishedTopic : '')!}';
        title +=
            ' + ${(conversation.subscribedTopic!.isNotEmpty ? conversation.subscribedTopic : '')!}';

        return ListTile(
          title: Text(title),
          subtitle: const Text('当前还有0条未读'),
          visualDensity: VisualDensity.comfortable,
          splashColor: Theme.of(context).colorScheme.inversePrimary,
          onTap: () {
            setState(() {
              _conversationId = conversation.id;
            });
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MessagePage(
                key: _messagePageKey,
                conversationId: conversation.id,
                mqttClient: _mqttClient,
              );
            })).then(
                (value) => (value == null || value) ? _enterAgain() : null);
          },
          onLongPress: () {
            debugPrint('编辑会话');
            setState(() {
              _conversationId = conversation.id;
              _publisherController.text =
                  (conversation.publishedTopic!.isNotEmpty
                      ? conversation.publishedTopic
                      : '')!;
              _receiverController.text =
                  (conversation.subscribedTopic!.isNotEmpty
                      ? conversation.subscribedTopic
                      : '')!;
            });
            mySimpleDialog(context, '编辑会话');
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () {
              deleteConversation(conversation.id).then((value) => {
                    if (value > 0)
                      {
                        if (conversation.subscribedTopic!.isNotEmpty)
                          {
                            _mqttClient.unsubscribeStringTopic(
                                conversation.subscribedTopic.toString())
                          },
                        queryConversationList()
                      }
                  });
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 0,
      ),
    );
  }

  // 查询已经存储的会话集合
  void queryConversationList({String? searchKey}) async {
    List<Conversation> conversationList =
        await getConversations(searchKey: searchKey, brokerId: initBrokerId);
    Broker? broker = await getBrokerById(id: initBrokerId);
    if (broker != null) {
      setState(() {
        _broker = broker;
      });

      if (!_connected) {
        MqttServerClient mqttClient = MqttServerClient(broker.host, '');
        setMqttClient(mqttClient, broker);
        setState(() {
          _mqttClient = mqttClient;
        });
      }
    }
    setState(() {
      _conversationList = conversationList;
      _conversationListLength = conversationList.length;
    });
  }

  // 新增话题弹窗
  void mySimpleDialog(BuildContext context, String dialogTitle) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dialogTitle,
                  style: const TextStyle(fontSize: 25),
                ),
                IconButton(
                  onPressed: () {
                    debugPrint("新增或修改某会话");
                    if (_publisherController.text.isNotEmpty ||
                        _receiverController.text.isNotEmpty) {
                      saveOrUpdateConversation().then((id) {
                        queryConversationList();
                        if (_receiverController.text.isNotEmpty) {
                          addMqttSubscribe(_receiverController.text);
                        }
                        Navigator.pop(context);
                      });
                    }
                  },
                  color: Colors.green[600],
                  icon: const Icon(Icons.save_rounded),
                )
              ],
            ),
            titlePadding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
            contentPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
                child: Column(
                  children: [
                    TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      controller: _publisherController,
                      decoration: const InputDecoration(
                        labelText: '发布主题名',
                        labelStyle: TextStyle(
                          fontSize: 15,
                        ),
                        hintText: '发布的topic',
                      ),
                    ),
                    TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      controller: _receiverController,
                      decoration: const InputDecoration(
                        labelText: '订阅主题名',
                        labelStyle: TextStyle(
                          fontSize: 15,
                        ),
                        hintText: '订阅的topic',
                        // icon: Icon(Icons.person),
                        // border: OutlineInputBorder(),
                      ),
                    ),
                    const Center(
                      child: Text(
                        '*发布或订阅topic至少填一个',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  // 新增/更新本地会话
  Future<int> saveOrUpdateConversation() async {
    int createdTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int modifiedTimestamp = createdTimestamp;
    int id;
    Map<String, dynamic> conversationMap = {
      'broker_id': initBrokerId,
      'published_topic': _publisherController.text,
      'subscribed_topic': _receiverController.text,
      'unread_amount': 0,
      'created_time': createdTimestamp,
      'modified_time': modifiedTimestamp
    };

    if (_conversationId == 0) {
      conversationMap['created_time'] = createdTimestamp;
      // 保存/更新至数据库
      id = await insertConversation(conversationMap);
    } else {
      conversationMap['id'] = _conversationId;
      id = await updateConversation(conversationMap);
    }
    return id;
  }

  void _enterAgain() {
    setState(() {
      _conversationId = 0;
    });
    queryConversationList();
  }

  Future<void> setMqttClient(MqttServerClient mqttClient, Broker broker) async {
    // 使用websocket连接
    if (broker.connectType == 'ws') {
      mqttClient.useWebSocket = true;
    }
    mqttClient.port = _broker.port; // ( or whatever your ws port is)
    /// You can also supply your own websocket protocol list or disable this feature using the websocketProtocols
    /// setter, read the API docs for further details here, the vast majority of brokers will support the client default
    /// list so in most cases you can ignore this.
    /// client.websocketProtocols = ['myString'];

    /// 是否打印mqtt日志信息
    mqttClient.logging(on: false);

    /// 设置端口号。创建时已经指定端口号就不需要设置。
    /// mqttClient.port = port;
    /// 设置协议版本，默认是3.1，根据服务器需要的版本来设置
    /// _client.setProtocolV31();
    /// 保持连接ping-pong周期。默认不设置时关闭。
    mqttClient.keepAlivePeriod = 60;

    /// 连接成功回调
    mqttClient.onConnected = onConnected;

    /// 连接断开回调
    mqttClient.onDisconnected = onDisconnected;

    /// 取消订阅回调
    mqttClient.onUnsubscribed = onUnsubscribed;

    /// 订阅成功回调
    mqttClient.onSubscribed = onSubscribed;

    /// 订阅失败回调
    mqttClient.onSubscribeFail = onSubscribeFail;

    /// ping pong响应回调
    mqttClient.pongCallback = pong;
    // 自动断线重连
    mqttClient.autoReconnect = true;

    // mqttClient.connect();
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await mqttClient.connect(broker.username, broker.password);
    } on MqttNoConnectionException catch (e) {
      // Raised by the client when connection fails.
      debugPrint('EXAMPLE::client exception - $e');
      setState(() {
        _appBarSubTitle = "Broker连接失败，请检查信息是否正确";
      });
      mqttClient.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      debugPrint('EXAMPLE::socket exception - $e');
      setState(() {
        _appBarSubTitle = "Socket连接失败，请检查信息是否正确";
      });
      mqttClient.disconnect();
    } on WebSocketException catch (e) {
      // Raised by the socket layer
      debugPrint('EXAMPLE::WebSocket exception - $e');
      setState(() {
        _appBarSubTitle = "WebSocket连接失败，请检查信息是否正确";
      });
      mqttClient.disconnect();
    }
  }

  void onConnected() {
    setState(() {
      _appBarSubTitle = "${_broker.host}:${_broker.port}已连接";
      _connected = true;
    });

    runSubscribeFun();
  }

  void onDisconnected() {
    debugPrint("断开连接");
  }

  void onUnsubscribed(MqttSubscription topic) {
    debugPrint("取消订阅 $topic");
  }

  void onSubscribed(MqttSubscription topic) {
    debugPrint("订阅 $topic 成功");
  }

  void onSubscribeFail(MqttSubscription topic) {
    debugPrint("订阅主题: $topic 失败");
  }

  void pong() {
    debugPrint("Ping的响应");
  }

  void addMqttSubscribe(String topic) {
    if (topic.isNotEmpty) {
      _mqttClient.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void runSubscribeFun() {
    if (_mqttClient.connectionStatus?.state == MqttConnectionState.connected) {
      if (_conversationList.isNotEmpty) {
        for (Conversation item in _conversationList) {
          if (item.subscribedTopic!.isNotEmpty) {
            addMqttSubscribe(item.subscribedTopic.toString());
          }
        }
        registerMessageListener();
      }
    }
  }

  void registerMessageListener() {
    _mqttClient.updates.listen((event) {
      MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      // 转成字符串
      String pt =
          const Utf8Decoder().convert(recMess.payload.message as List<int>);
      String? subscribedTopic = event[0].topic;
      if (subscribedTopic != null) {
        debugPrint("接收到了主题$subscribedTopic的消息： $pt");
        getConversationsBySubscribedTopic(
                subscribedTopic: subscribedTopic, brokerId: _broker.id)
            .then((conversationList) {
          if (conversationList.isNotEmpty) {
            for (Conversation conversation in conversationList) {
              Map<String, dynamic> map = {
                'conversation_id': conversation.id,
                'type': 2,
                'topic': subscribedTopic,
                'content': pt,
                'created_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
              };
              insertMessage(map);

              if (_conversationId == conversation.id) {
                _messagePageKey.currentState?.queryMessageList();
              }
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _publisherController.dispose();
    // _receiverController.dispose();
    if (_connected) {
      _mqttClient.disconnect();
    }
  }
}
