import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/pojo/dualPanel.dart';
import 'package:mqtt_client/store/conversationManageProvider.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';
import 'package:mqtt_client/views/add_client.dart';
import 'package:mqtt_client/views/conversation_manage/index.dart';
import 'package:mqtt_client/views/empty_page.dart';
import 'package:provider/provider.dart';

import '../pojo/broker.dart';
import '../store/HomePageProvider.dart';
import '../store/clientAddProvider.dart';

// class HomePage extends StatelessWidget {
//
//   static const routeName = 'HomePage';
//
//   const HomePage({super.key});
//
//   void reloadPage() {
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const HomePageFul();
//   }
// }

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage> {
  List<Broker> _brokerList = [];
  bool refresh = false;

  @override
  void initState() {
    super.initState();
    // queryBrokerList();
  }

  @override
  Widget build(BuildContext context) {
    DualPanel dualPanel = context.read<DualPanel>();
    ClientAddProvider clientAddProvider = context.read<ClientAddProvider>();
    ConversationManageProvider conversationManageProvider = context.read<ConversationManageProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(
          child: Text('MQTT客户端'),
          ),
        automaticallyImplyLeading: false
      ),
      body: dataList(dualPanel, clientAddProvider, conversationManageProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          addButtonHandler(clientAddProvider, dualPanel)
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget dataList(DualPanel dualPanel, ClientAddProvider clientAddProvider, ConversationManageProvider conversationManageProvider) {
    HomePageProvider homePageProvider = context.watch<HomePageProvider>();
    homePageProvider.queryBrokerList();

    List<Broker> brokerList = homePageProvider.getBrokerList;
    if (brokerList.isEmpty) {
      return const Center(
        child: Text('暂无Broker服务器'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: brokerList.length,
      itemBuilder: (BuildContext context, int index) {
        Broker broker = brokerList[index];
        return ListTile(
          title: Text('${index + 1} - ${broker.alias}'),
          subtitle: Text('${broker.host}:${broker.port}'),
          visualDensity: VisualDensity.comfortable,
          splashColor: Theme.of(context).colorScheme.inversePrimary,
          onTap: () {
            dualPanel.routerPush(context, "ConversationManagePage", {});
            conversationManageProvider.inputBroker(broker);
          },
          onLongPress: () {
            clientAddProvider.queryBroker(broker.id);
            dualPanel.routerPush(context, ClientAddFul.routeName, {});
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

  void reloadData() {
    queryBrokerList();
  }

  void addButtonHandler(ClientAddProvider clientAddProvider, DualPanel dualPanel) {
    clientAddProvider.queryBroker(0);

    dualPanel.routerPush(context, ClientAddFul.routeName, {"brokerId": 0});
  }

  @override
  void dispose() {
    super.dispose();
  }
}