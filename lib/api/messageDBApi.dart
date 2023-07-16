import '../pojo/message.dart';
import '../utils/DatabaseUtils.dart';

Future<int> insertMessage(Map<String, dynamic> messageMap) async {
  final db = await DatabaseUtils.instance.database;
  return await db.insert('message', messageMap);
}

Future<int> deleteMessage(int id) async {
  final db = await DatabaseUtils.instance.database;
  return await db.delete('message', where: 'id = ?', whereArgs: [id]);
}

Future<int> deleteBatchMessage(List<int> ids) async {
  final db = await DatabaseUtils.instance.database;
  if (ids.isEmpty) {
    return 0;
  }

  String idStr = ids.join(',');
  return await db.delete('message', where: 'id in ?', whereArgs: [idStr]);
}

Future<List<Message>> getMessages(
    {String? searchKey, required int conversationId}) async {
  var where =
      (searchKey != null && searchKey.isNotEmpty) ? 'content LIKE ?' : null;
  var whereArgs =
      (searchKey != null && searchKey.isNotEmpty) ? ['%$searchKey%'] : null;

  if (where != null && whereArgs != null) {
    where += 'AND conversation_id = ?';
    whereArgs[2] = '$conversationId';
  } else {
    where = 'conversation_id = ?';
    whereArgs = ['$conversationId'];
  }

  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'message',
    orderBy: 'created_time DESC',
    where: where,
    whereArgs: whereArgs,
  );
  return List.generate(maps.length, (i) {
    return Message.fromMap(maps[i]);
  });
}
