import 'package:flutter/material.dart';
import 'package:messagebottle/models/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:messagebottle/providers/message_list_provider.dart';

class ReplyScreen extends StatefulWidget {
  final Message message;

  const ReplyScreen({Key? key, required this.message}) : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final _formKey = GlobalKey<FormState>();

  String replyText = '';
  Database? _db;

  @override
  void initState() {
    super.initState();

    _initDb().then((_) {
      updateReadStatus();
    });
  }

  Future<void> _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'messagebottle.db');

    _db = await openDatabase(
      path,
      version: 1,
    );
  }

  void updateReadStatus() async {
    // 既読フラグを更新します。
    widget.message.isRead = true;

    // データベースを更新します。
    await _db?.update(
      'message_list',
      widget.message.toMap(),
      where: 'messageId = ?',
      whereArgs: [widget.message.messageId],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Reply to this message:'),
            ),
            TextFormField(
              maxLines: null,
              onChanged: (value) {
                replyText = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  // メッセージの内容を更新します。
                  String updatedContent =
                      '$replyText\n---- ${DateTime.now()} ----\n${widget.message.content}';
                  widget.message.updateReply(updatedContent);
                  // メッセージを送信します。
                  Provider.of<MessageListProvider>(context, listen: false)
                      .sendMessage(widget.message, true);
                  Navigator.of(context).pop(); // 返信後、前の画面に戻ります。
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // ここで文字の色を指定します。
                backgroundColor: Colors.blue, // ここでボタンの背景色を指定します。
              ),
              child: const Text('Send'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 元のメッセージを表示します。
                  Text(widget.message.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
