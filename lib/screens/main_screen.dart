import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:messagebottle/models/message.dart';
import 'package:messagebottle/providers/message_list_provider.dart';
import 'package:messagebottle/screens/reply_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MessageListProviderのインスタンスを取得します。
    final messageProvider = Provider.of<MessageListProvider>(context);
    // DBからメッセージを取得します。
    messageProvider.fetchMessagesFromDb();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: FutureBuilder(
        // ここでfetchMessagesメソッドを呼び出して、メッセージを取得します。
        // future: messageProvider.fetchMessages(), // TODO いったんコメントアウトします。
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // メッセージがまだロード中の場合、スピナーを表示します。
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            // エラーが発生した場合、エラーメッセージを表示します。
            return const Center(child: Text('An error occurred!'));
          } else {
            return Consumer<MessageListProvider>(
              builder: (context, messageProvider, child) {
                return ListView.builder(
                  itemCount: messageProvider.messageList.length,
                  itemBuilder: (context, index) {
                    final reversedIndex =
                        messageProvider.messageList.length - index - 1;
                    final message = messageProvider.messageList[reversedIndex];
                    return ListTile(
                      title: Text(
                        message.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(message.sentAt.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (!message.isRead)
                            const Icon(
                              Icons.mark_email_unread, // 未読のメッセージには未読アイコンを表示します
                              color: Colors.green,
                            ),
                          if (message.isReplied)
                            const Icon(
                              Icons.reply, // 返信済みのメッセージには返信アイコンを表示します
                              color: Colors.blue,
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReplyScreen(
                                    message: messageProvider
                                        .messageList[reversedIndex])));
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController _controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New Message'),
                content: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "Enter your message"),
                  maxLines: null, // ユーザーが新しい行を開始するたびにテキストフィールドが拡張するように設定します
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      // 新規メッセージの作成
                      Message newMessage = Message(
                        messageId: "", // IDはsendMessage関数で設定します
                        content: _controller.text, // ユーザーの入力内容
                        sentAt: DateTime.now().toString(), // 送信日時
                      );
                      messageProvider.sendMessage(newMessage, false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
