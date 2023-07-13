import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "messagebottle.db";
  static const _databaseVersion = 1;

  static const table = "message_list";

  static const columnSenderId = "sender_id";
  static const columnMessageId = "message_id";
  static const columnContent = "content";
  static const columnReadFlag = "read_flag";
  static const columnRepliedFlag = "replied_flag";
  static const columnSentDate = "sent_date";

  // Singleton instance
  static DatabaseHelper? _databaseHelper;

  // Singleton accessor
  static DatabaseHelper? get instance {
    _databaseHelper ??= DatabaseHelper._();
    return _databaseHelper;
  }

  // A private constructor
  DatabaseHelper._();

  // Database instance
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnSenderId TEXT NOT NULL,
        $columnMessageId TEXT PRIMARY KEY,
        $columnContent TEXT NOT NULL,
        $columnReadFlag INTEGER NOT NULL,
        $columnRepliedFlag INTEGER NOT NULL,
        $columnSentDate TEXT NOT NULL
      )
      ''');
  }
}
