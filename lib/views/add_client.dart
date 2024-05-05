import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mqtt_client/pojo/dualPanel.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../pojo/broker.dart';

class ClientAddFul extends StatefulWidget {

  static const routeName = 'ClientAdd';

  // 数据库id,没有时传0
  final Map arguments;

  const ClientAddFul({
    super.key,
    required this.arguments,
    // required this.database
  });

  @override
  State<StatefulWidget> createState() {
    return ClientAddState();
  }
}

class ClientAddState extends State<ClientAddFul> {
  int initBrokerId = 0;
  Uuid uuid = const Uuid();
  int _brokerId = 0;
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _connectType = 'tcp';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    int brokerId = widget.arguments['brokerId'];
    setState(() {
      initBrokerId = brokerId;
    });

    if (initBrokerId != 0) {
      queryBroker();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // leading: IconButton(
          //   icon: const Icon(Icons.close),
          //   onPressed: () {
          //     context.read<DualPanel>().endPanelPop(context);
          //   },
          // ),
          title: const Center(
            child: Text(
              '添加Broker',
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  debugPrint('保存按钮');
                  // print(broker.toJson());
                  if (validateForm()) {
                    if (_connectType == 'ws' &&
                        !_hostController.text.startsWith('ws://') &&
                        !_hostController.text.startsWith('wss://')) {
                      _hostController.text = 'ws://${_hostController.text}';
                    }
                    saveOrUpdateBroker().then((id) => {
                          Navigator.pop(context, true),
                        });
                  }
                },
                icon: const Icon(Icons.save)),
            IconButton(
              onPressed: () {
                debugPrint('删除按钮');
                if (_brokerId != 0) {
                  deleteBroker(_brokerId);
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.delete_forever_rounded),
            )
            ],
          // automaticallyImplyLeading: false
        ),
        body: loginForm());
  }

  Widget loginForm() {
    if (_brokerId == 0 && initBrokerId != 0) {
      // 编辑时先载loading动画
      return Center(
        child: LoadingAnimationWidget.newtonCradle(
          color: const Color(0xFFEA3799),
          size: 200,
        ),
      );
    }

    return Padding(
        //symmetric代表着对称，其vertical代表上下对称，horizontal代表左右对称        //symmetric代表着对称，其vertical代表上下对称，horizontal代表左右对称
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            // 自动校验方式
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    controller: _aliasController,
                    decoration: const InputDecoration(
                      labelText: '别名',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                      hintText: '当前配置的别名',
                      // icon: Icon(Icons.person),
                      // border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    //校验用户名
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '别名不可为空';
                      }
                      return null;
                    }),
                TextFormField(
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _clientIdController,
                  decoration: InputDecoration(
                      labelText: '客户端ID',
                      labelStyle: const TextStyle(
                        fontSize: 20,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          debugPrint("随机生成客户端ID");
                          _clientIdController.text =
                              uuid.v1().replaceAll("-", "");
                        },
                        icon: const Icon(Icons.autorenew),
                      )),
                  // 表单校验
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '客户端ID不可为空';
                    }
                    return null;
                    return null;
                  },
                ),
                DropdownButtonFormField(
                    value: _connectType,
                    hint: const Text("连接方式"),
                    items: const [
                      DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                      DropdownMenuItem(value: 'ws', child: Text('WebSocket')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _connectType = value;
                          if (!_hostController.text.startsWith('ws://') &&
                              !_hostController.text.startsWith('wss://')) {
                            _hostController.text =
                                'ws://${_hostController.text}';
                          }
                        });
                      }
                    }),
                TextFormField(
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _hostController,
                  decoration: const InputDecoration(
                      labelText: '服务器地址',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      ),
                      hintText: 'broker服务器的地址(包括path)'),
                  // 表单校验
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '服务器地址不可为空';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: '端口',
                    labelStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  // 表单校验
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '端口号不可为空';
                    }
                    return null;
                  },
                ),
                TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        labelText: '用户名',
                        labelStyle: TextStyle(
                          fontSize: 20,
                        ),
                        hintText: '如果有的的话需要输入')),
                TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        labelText: '密码',
                        labelStyle: TextStyle(
                          fontSize: 20,
                        ),
                        hintText: '如果有的的话需要输入'))
              ],
            ),
          ),
        ));
  }

  void queryBroker() async {
    Broker? broker = await getBrokerById(id: initBrokerId);
    if (broker != null) {
      setState(() {
        _brokerId = broker.id;
        _aliasController.text = broker.alias;
        _connectType = broker.connectType;
        _hostController.text = broker.host;
        _portController.text = broker.port.toString();
        _usernameController.text = broker.username!;
        _passwordController.text = broker.password!;
        _clientIdController.text = broker.clientId;
      });
    }
  }

  // 保存/更新broker到数据库
  Future<int> saveOrUpdateBroker() async {
    int createdTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int modifiedTimestamp = createdTimestamp;
    int id;
    Map<String, dynamic> brokerMap = {
      'alias': _aliasController.text,
      'connect_type': _connectType,
      'host': _hostController.text,
      'port': _portController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'client_id': _clientIdController.text,
      'modified_time': modifiedTimestamp,
    };
    if (_brokerId == 0) {
      brokerMap['created_time'] = createdTimestamp;
      // 保存/更新至数据库
      id = await insertBroker(brokerMap);
    } else {
      brokerMap['id'] = _brokerId;
      id = await updateBroker(brokerMap);
    }
    return id;
  }

  bool validateForm() {
    final form = _formKey.currentState!;
    return form.validate();
  }

  @override
  void dispose() {
    super.dispose();
    // db.dispose();
  }
}
