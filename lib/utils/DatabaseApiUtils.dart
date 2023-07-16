import 'package:mqtt_client/pojo/broker.dart';
import 'DatabaseUtils.dart';

Future<int> insertBroker(Map<String, dynamic> brokerMap) async {
  final db = await DatabaseUtils.instance.database;
  return await db.insert('broker', brokerMap);
}

Future<int> updateBroker(Map<String, dynamic> brokerMap) async {
  final db = await DatabaseUtils.instance.database;
  return await db.update('broker', brokerMap,
      where: 'id = ?', whereArgs: [brokerMap['id']]);
}

Future<int> deleteBroker(int id) async {
  final db = await DatabaseUtils.instance.database;
  return await db.delete('broker', where: 'id = ?', whereArgs: [id]);
}

Future<List<Broker>> getBrokers({String? searchKey}) async {
  var where = (searchKey != null && searchKey.isNotEmpty)
      ? 'alias LIKE ? OR host LIKE ?'
      : null;
  var whereArgs = (searchKey != null && searchKey.isNotEmpty)
      ? ['%$searchKey%', '%$searchKey%']
      : null;
  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'broker',
    orderBy: 'modified_time DESC',
    where: where,
    whereArgs: whereArgs,
  );
  return List.generate(maps.length, (i) {
    return Broker.fromMap(maps[i]);
  });
}

Future<Broker?> getBrokerById({int? id}) async {
  String where = 'id = ?';
  List<dynamic> whereArgs = [id];
  final db = await DatabaseUtils.instance.database;
  final List<Map<String, dynamic>> maps =
      await db.query('broker', where: where, whereArgs: whereArgs, limit: 1);
  if (maps.isEmpty) {
    return null;
  }
  return Broker.fromMap(maps.first);
}
