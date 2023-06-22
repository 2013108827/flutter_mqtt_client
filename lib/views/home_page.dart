
import 'package:flutter/material.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';
import 'package:mqtt_client/views/add_client.dart';
import 'package:mqtt_client/views/conversation_manage/index.dart';

import '../pojo/broker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageFul();
  }

}

class HomePageFul extends StatefulWidget {
  const HomePageFul({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePageFul> {

  List<Broker> _brokerList = [];

  @override
  void initState() {
    super.initState();
    queryBrokerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(
          child: Text('MQTT客户端'),
        ),
      ),
      body: dataList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) {
            return const ClientAddFul(
                brokerId: 0,
            );
          })).then((value) => (value == null || value) ? _enterAgain() : null)
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  Widget dataList() {
    if (_brokerList.isEmpty) {
      return const Center(
        child: Text('暂无Broker服务器'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _brokerList.length,
      itemBuilder: (BuildContext context, int index) {
        Broker broker = _brokerList[index];
        return ListTile(
          title: Text('${index+1} - ${broker.alias}'),
          subtitle: Text('${broker.host}:${broker.port}'),
          visualDensity: VisualDensity.comfortable,
          splashColor: Theme.of(context).colorScheme.inversePrimary,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return ConversationManage(
                    brokerId: broker.id,
                    brokerAlias: broker.alias,
                  );
                })).then((value) => (value == null || value) ? _enterAgain() : null);
          },
          onLongPress: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return ClientAddFul(
                    brokerId: broker.id,
                  );
                })).then((value) => (value == null || value) ? _enterAgain() : null);
          },
          // trailing: IconButton(
          //   icon: const Icon(Icons.delete_forever_outlined),
          //   onPressed: () {
          //     _deleteMemo(memo);
          //   },
          // ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 0,
      ),
    );
  }

  // 查询已经存储的broker集合
  void queryBrokerList({String? searchKey}) async {
    List<Broker> brokerList = await getBrokers(searchKey: searchKey);
    // for (Broker broker in brokerList) {
    //   print(broker.toJson());
    // }
    setState(() {
      _brokerList = brokerList;
    });
  }
  
  void _enterAgain() {
    queryBrokerList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}