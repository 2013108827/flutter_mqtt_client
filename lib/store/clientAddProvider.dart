
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/pojo/broker.dart';
import 'package:mqtt_client/utils/DatabaseApiUtils.dart';

class ClientAddProvider with ChangeNotifier {

  Broker? broker;

  Broker? get getBroker => broker;

  void queryBroker(int brokerId) {
    getBrokerById(id: brokerId).then((value) {
      broker = value;
      notifyListeners();
    });
  }


}