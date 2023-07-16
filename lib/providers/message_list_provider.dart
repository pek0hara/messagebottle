import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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

      // TODO データベース登録処理
      // // データベースを更新します。
      // if (_db == null) {
      //   await _initDb();
      // }
      // // データベースに全件追加します。
      // await _db?.insert('message_list', fetchedMessages.toMap(),
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );

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
      where: 'messageId = ?',
      whereArgs: [message.messageId],
    );
    notifyListeners();
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> updateMessage(Message message) async {
    if (_db == null) {
      await _initDb();
    }

    await _db?.update(
      'message_list',
      message.toMap(),
      where: 'messageId = ?',
      whereArgs: [message.messageId],
    );

    notifyListeners();
  }

  Future<void> sendMessage(Message message, bool replyFlg) async {
    if (_db == null) {
      await _initDb();
    }

    // TODO デバッグ用処理
    if (replyFlg) {
      // 返信の場合は、メッセージを更新します。
      message.updateReply(message.content);
      await updateMessage(message);
    } else {
      // 返信でない場合は、メッセージを追加します。
      await _db?.insert('message_list', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // // メッセージを送信します。
    // String url = 'http://example.com/sendMessage'; // 送信先のURLを設定します。
    //
    // Map<String, String> headers = {"Content-type": "application/json"};
    //
    // var userId = await getUserId();
    //
    // Map<String, String> body = {
    //   'messageId': message.messageId,
    //   'fromId': userId!,
    //   'toId': message.senderId,
    //   'content': message.content,
    //   'sentAt': message.sentAt,
    // };
    //
    // String json = jsonEncode(body); // ボディデータをJSONにエンコードします。
    //
    // try {
    //   var response = await http.post(
    //     Uri.parse(url),
    //     headers: headers,
    //     body: json,
    //   );
    //
    //   if (response.statusCode == 200) {
    //     if (replyFlg) {
    //       message.updateReply(message.content);
    //       await updateMessage(message);
    //     }
    //   } else {
    //     print('Failed to send message: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Error occurred while sending message: $e');
    // }
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
            messageId TEXT PRIMARY KEY,
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
