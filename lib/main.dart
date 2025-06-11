import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String serverUrl = 'http://127.0.0.1:3000'; // Use your server IP

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket.IO Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(serverUrl: serverUrl),
      debugShowCheckedModeBanner: false,
    );
  }
}
