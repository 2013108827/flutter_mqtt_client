class Message {
  late int id;
  // 会话id
  late int conversationId;
  // 类型。1：主动发送的消息，2：被动接收到的消息
  late int type;
  // 哪个topic发出/发来的
  late String topic;
  late String content;
  late DateTime createdTime;

  Message(
      {required this.id,
      required this.conversationId,
      required this.type,
      required this.topic,
      required this.content,
      required this.createdTime});

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    type = json['type'];
    topic = json['topic'];
    content = json['content'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversationId'] = conversationId;
    data['type'] = type;
    data['topic'] = topic;
    data['content'] = content;
    data['createdTime'] = createdTime;
    return data;
  }

  // 数据库插入时使用
  Map<String, dynamic> toMap() {
    var createdTimestamp = createdTime.millisecondsSinceEpoch ~/ 1000;
    return {
      'id': id,
      'conversation_id': conversationId,
      'type': type,
      'topic': topic,
      'content': content,
      'created_time': createdTimestamp,
    };
  }

  // 数据库查询时使用
  factory Message.fromMap(Map<String, dynamic> map) {
    var createdTimestamp = map['created_time'] as int;
    return Message(
      id: map['id'] as int,
      conversationId: map['conversation_id'] as int,
      type: map['type'] as int,
      topic: map['topic'],
      content: map['content'] as String,
      createdTime: DateTime.fromMillisecondsSinceEpoch(createdTimestamp * 1000),
    );
  }
}
