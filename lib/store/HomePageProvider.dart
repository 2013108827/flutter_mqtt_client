
import 'package:flutter/cupertino.dart';

import 'package:mqtt_client/pojo/broker.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';

class HomePageProvider with ChangeNotifier {

  List<Broker> brokerList = [];

  List<Broker> get getBrokerList => brokerList;

  void queryBrokerList() {
    // Dart在执行完一轮同步代码前，是不会管异步代码的
     getBrokers(searchKey: '').then((value) {
       brokerList = value;
       notifyListeners();
     });
  }

}