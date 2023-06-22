
import '../pojo/conversation.dart';
import '../utils/DatabaseUtils.dart';

Future<int> insertConversation(Map<String, dynamic> conversationMap) async {
  final db = await DatabaseUtils.instance.database;
  return await db.insert('conversation', conversationMap);
}

Future<int> updateConversation(Map<String, dynamic> conversationMap) async {
  final db = await DatabaseUtils.instance.database;
  return await db
      .update('conversation', conversationMap, where: 'id = ?', whereArgs: [conversationMap['id']]);
}

Future<int> deleteConversation(int id) async {
  final db = await DatabaseUtils.instance.database;
  return await db.delete('conversation', where: 'id = ?', whereArgs: [id]);
}

Future<List<Conversation>> getConversations({String? searchKey, required int brokerId}) async {
  var where = (searchKey != null && searchKey.isNotEmpty) ? 'published_topic LIKE ? OR subscribed_topic LIKE ?' : null;
  var whereArgs = (searchKey != null && searchKey.isNotEmpty) ? ['%$searchKey%', '%$searchKey%'] : null;

  if (where != null && whereArgs != null && brokerId != null) {
    where += 'AND broker_id = ?';
    whereArgs[2] = '$brokerId';
  } else {
    where = 'broker_id = ?';
    whereArgs = ['$brokerId'];
  }

  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'conversation',
    orderBy: 'modified_time DESC',
    where: where,
    whereArgs: whereArgs,
  );
  return List.generate(maps.length, (i) {
    return Conversation.fromMap(maps[i]);
  });
}

Future<Conversation?> getConversationById({int? id}) async {
  String where = 'id = ?';
  List<dynamic> whereArgs = [id];
  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
      'conversation',
      where: where,
      whereArgs: whereArgs,
      limit: 1
  );
  if (maps.isEmpty) {
    return null;
  }
  return Conversation.fromMap(maps.first);
}

Future<List<Conversation>> getConversationsBySubscribedTopic({required String subscribedTopic, required int brokerId}) async {
  var where = (subscribedTopic.isNotEmpty) ? 'subscribed_topic = ?' : null;
  var whereArgs = (subscribedTopic.isNotEmpty) ? [subscribedTopic] : null;

  if (where != null && whereArgs != null) {
    where += 'AND broker_id = ?';
    whereArgs.add('$brokerId');
  } else {
    where = 'broker_id = ?';
    whereArgs = ['$brokerId'];
  }

  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'conversation',
    orderBy: 'modified_time DESC',
    where: where,
    whereArgs: whereArgs,
  );
  return List.generate(maps.length, (i) {
    return Conversation.fromMap(maps[i]);
  });
}