import 'package:path/path.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:sqflite/sqflite.dart';

import 'models/list_item.dart';

class DBHelper {
  final int version = 1;
  Database db;

// Singleton Implementation
  static final DBHelper _dbHelper = DBHelper._internal();

  DBHelper._internal();

  factory DBHelper() {
    return _dbHelper;
  }

  //

  Future<Database> openDB() async {
    if (db == null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'shopping.db');
      this.db = await openDatabase(path, version: version,
          onCreate: (database, version) async {
        await database.execute('CREATE TABLE lists(id INTEGER PRIMARY KEY, ' +
            'name TEXT, priority INTEGER)');
        await database.execute('CREATE TABLE items(id INTEGER PRIMARY KEY, ' +
            'idList INTEGER, name TEXT, quantity TEXT, note TEXT, ' +
            'FOREIGN KEY(idList) REFERENCES lists(id))');
      });
    }
    return db;
  }

  Future testDB() async {
    db = await openDB();
    await db.execute('INSERT INTO lists VALUES (0, "Fruit", 2)');
    await db.execute('INSERT INTO items VALUES (0, 0, "Apples", ' +
        '"2 Kg", "Better if they are green")');
    List lists = await db.rawQuery('select * from lists');
    List items = await db.rawQuery('select * from items');
    print(lists[0].toString());
    print(items[0].toString());
  }

  Future<int> insertList(ShoppingList list) async {
    list.id = await db.insert('lists', list.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return list.id;
  }

  Future<int> insertItem(ListItem item) async {
    item.id = await db.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return item.id;
  }

  Future<List<ShoppingList>> getLists() async {
    await openDB();
    List<Map<String, dynamic>> maps = await db.query('lists');
    return List.generate(maps.length, (i) {
      return ShoppingList(maps[i]['id'], maps[i]['name'], maps[i]['priority']);
    });
  }

  Future<List<ListItem>> getItems(int idList) async {
    await openDB();
    List<Map<String, dynamic>> maps =
        await db.query('items', where: 'idList = ?', whereArgs: [idList]);
    return List.generate(maps.length, (i) {
      return ListItem(maps[i]['id'], maps[i]['idList'], maps[i]['name'],
          maps[i]['quantity'], maps[i]['note']);
    });
  }

  Future<int> deleteList(ShoppingList list) async {
    await db.delete('items', where: 'idList = ?', whereArgs: [list.id]);
    int result =
        await db.delete('lists', where: 'id = ?', whereArgs: [list.id]);
    return result;
  }

  Future<int> deleteItem(ListItem item) async {
    int result =
        await db.delete('items', where: 'id = ?', whereArgs: [item.id]);
    return result;
  }
}
