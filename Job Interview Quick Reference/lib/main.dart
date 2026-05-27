import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'QuestionPage.dart';
import 'AnswerPage.dart';
import 'QuestionModel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuestionProvider(), // データ管理クラスを起動
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '面接クイックリファレンス',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ネイビー系（0xFF1A375D）
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A375D)),
        useMaterial3: true,
      ),
      home: const Questionpage(), // 起動時に一覧画面を表示
    );
  }
}
