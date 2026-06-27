import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  var db = await databaseFactory.openDatabase('assets/db/recipes_catalog.db');
  var results = await db.query('recipes', limit: 3);
  for (var r in results) {
    print(r['instructions']);
    print('---');
  }
  await db.close();
}
