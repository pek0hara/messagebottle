import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:messagebottle/providers/message_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:messagebottle/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessageListProvider>(
      create: (context) => MessageListProvider(),
      child: MaterialApp(
        home: FutureBuilder<String>(
          future: getUserId(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // まだUUIDを取得していないときはローディング表示
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // UUIDを取得したらMainScreenを表示
                return const Scaffold(
                  body: MainScreen(),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('userId');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('userId', userId);
    }

    return userId;
  }
}
