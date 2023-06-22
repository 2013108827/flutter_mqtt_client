
class Conversation {
  late int id;
  late int brokerId;
  String? publishedTopic;
  String? subscribedTopic;
  int? unreadAmount;
  late DateTime createdTime;
  late DateTime modifiedTime;

  Conversation({
    required this.id,
    required this.brokerId,
    this.publishedTopic,
    this.subscribedTopic,
    this.unreadAmount,
    required this.createdTime,
    required this.modifiedTime
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brokerId = json['brokerId'];
    publishedTopic = json['publishedTopic'];
    subscribedTopic = json['subscribedTopic'];
    unreadAmount = json['unreadAmount'];
    createdTime = json['createdTime'];
    modifiedTime = json['modifiedTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['brokerId'] = brokerId;
    data['publishedTopic'] = publishedTopic;
    data['subscribedTopic'] = subscribedTopic;
    data['unreadAmount'] = unreadAmount;
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
      'broker_id': brokerId,
      'published_topic': publishedTopic,
      'subscribed_topic': subscribedTopic,
      'unread_amount': unreadAmount,
      'created_time': createdTimestamp,
      'modified_time': modifiedTimestamp
    };
  }

  // 数据库查询时使用
  factory Conversation.fromMap(Map<String, dynamic> map) {
    var createdTimestamp = map['created_time'] as int;
    var modifiedTimestamp = map['modified_time'] as int;
    return Conversation(
      id: map['id'] as int,
      brokerId: map['broker_id'] as int,
      publishedTopic: map['published_topic'] as String,
      subscribedTopic: map['subscribed_topic'] as String,
      unreadAmount: map['unread_amount'] as int,
      createdTime: DateTime.fromMillisecondsSinceEpoch(createdTimestamp * 1000),
      modifiedTime: DateTime.fromMillisecondsSinceEpoch(modifiedTimestamp * 1000),
    );
  }
}
