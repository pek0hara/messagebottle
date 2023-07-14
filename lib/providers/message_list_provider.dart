import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:messagebottle/models/message.dart';

class MessageListProvider with ChangeNotifier {
  List<Message> _messageList = [];
  static Database? _db;

  List<Message> get messageList => _messageList;

  Future<List<Message>> fetchMessagesFromDb() async {
    if (_db == null) {
      await _initDb();
    }

    final List<Map<String, dynamic>> maps = await _db!.query('message_list');

    _messageList = List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });

    notifyListeners();

    return _messageList;
  }

  Future<void> fetchMessages() async {
    // HTTPリクエストを使ってサーバからメッセージを取得します。この例ではダミーのURLを使用しています。
    final response = await http.get(Uri.parse('https://example.com/messages'));

    if (response.statusCode == 200) {
      // サーバからの応答が成功した場合、メッセージをパースします。
      List<Message> fetchedMessages = (json.decode(response.body) as List)
          .map((data) => Message.fromJson(data))
          .toList();
      _messageList = fetchedMessages;
      notifyListeners();
    } else {
      // 応答が成功しなかった場合、エラーをスローします。
      throw Exception('Failed to load messages');
    }
  }

  void addMessage(Message message) {
    _messageList.insert(0, message);
    notifyListeners();
  }

  void updateReadStatus(Message message) {
    message.isRead = true;
    _db?.update(
      'message_list',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
    notifyListeners();
  }

  Future<void> sendMessage(Message message) async {
    if (_db == null) {
      await _initDb();
    }

    var uuid = const Uuid();
    String messageId = uuid.v4();
    message.id = messageId;

    await _db?.insert(
      'message_list',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // TODO ここにメッセージを送信する処理を書きます。
  }

  Future<void> _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'messagebottle.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE message_list (
            id TEXT PRIMARY KEY,
            senderId TEXT,
            content TEXT,
            isRead INTEGER,
            isReplied INTEGER,
            sentAt TEXT
          )
        ''');
      },
    );
  }
}
