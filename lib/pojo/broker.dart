class Broker {
  late int id;
  late String alias;
  late String connectType;
  late String host;
  late int port;
  String? username;
  String? password;
  late String clientId;
  late DateTime createdTime;
  late DateTime modifiedTime;

  Broker(
      {required this.id,
      required this.alias,
      required this.connectType,
      required this.host,
      required this.port,
      this.username,
      this.password,
      required this.clientId,
      required this.createdTime,
      required this.modifiedTime});

  Broker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alias = json['alias'];
    connectType = json['connectType'];
    host = json['host'];
    port = json['port'];
    username = json['username'];
    password = json['password'];
    clientId = json['clientId'];
    createdTime = json['createdTime'];
    modifiedTime = json['modifiedTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['alias'] = alias;
    data['connectType'] = connectType;
    data['host'] = host;
    data['port'] = port;
    data['username'] = username;
    data['password'] = password;
    data['clientId'] = clientId;
    data['createdTime'] = createdTime;
    data['modifiedTime'] = modifiedTime;
    return data;
  }

  // 数据库插入时使用
  Map<String, dynamic> toMap() {
    var createdTimestamp = createdTime.millisecondsSinceEpoch ~/ 1000;
    var modifiedTimestamp = modifiedTime.millisecondsSinceEpoch ~/ 1000;
    return {
      'id': id,
      'alias': alias,
      'connect_type': connectType,
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'client_id': clientId,
      'created_time': createdTimestamp,
      'modified_time': modifiedTimestamp
    };
  }

  // 数据库查询时使用
  factory Broker.fromMap(Map<String, dynamic> map) {
    var createdTimestamp = map['created_time'] as int;
    var modifiedTimestamp = map['modified_time'] as int;
    return Broker(
      id: map['id'] as int,
      alias: map['alias'] as String,
      connectType: map['connect_type'] as String,
      host: map['host'] as String,
      port: map['port'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      clientId: map['client_id'] as String,
      createdTime: DateTime.fromMillisecondsSinceEpoch(createdTimestamp * 1000),
      modifiedTime:
          DateTime.fromMillisecondsSinceEpoch(modifiedTimestamp * 1000),
    );
  }
}
