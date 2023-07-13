import 'package:flutter/material.dart';
import 'package:messagebottle/models/message.dart';

class ReplyScreen extends StatefulWidget {
  final Message message;

  const ReplyScreen({Key? key, required this.message}) : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String replyText = '';

  void _sendReply(BuildContext context) {
    // ここでHTTPリクエストを使ってサーバーに返信を送る処理を記述します。
    // 以下はダミーのコードです。
    print('Reply sent: $replyText');
    Navigator.of(context).pop(); // 返信後、前の画面に戻ります。
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply to ${widget.message.senderId}'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 元のメッセージを表示します。
                  const Text('Replying to:'),
                  Text(widget.message.content),
                ],
              ),
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
                  _sendReply(context);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // ここで文字の色を指定します。
                backgroundColor: Colors.blue, // ここでボタンの背景色を指定します。
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
