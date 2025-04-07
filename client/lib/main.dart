import 'package:flutter/material.dart';
import 'pages/score_home_page.dart';


void main() {
  runApp(MyApp());
}

/// 主入口 App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '曲谱 App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScoreHomePage(),
    );
  }
}




