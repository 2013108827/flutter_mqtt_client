
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/pojo/broker.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';

class ConversationManageProvider with ChangeNotifier {

  late Broker broker;

  Broker get getBroker => broker;

  // void inputBroker(Broker brokerItem) {
  //   Future future = Future(() => broker = brokerItem);
  //   future.then((_) => notifyListeners());
  // }

  void inputBroker(Broker brokerItem) {
    broker = brokerItem;
    notifyListeners();
  }
}