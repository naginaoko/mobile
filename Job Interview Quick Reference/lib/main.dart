import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. これを追加（Providerの仕組みを使うため）
import 'QuestionPage.dart';
import 'AnswerPage.dart';
import 'QuestionModel.dart';

void main() {
  // 2. runAppの中身を「ChangeNotifierProvider」で包むように修正します
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
        // お好みでテーマカラーをネイビー系（0xFF1A375D）に合わせると統一感が出ます
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A375D)),
        useMaterial3: true,
      ),
      home: const Questionpage(), // 起動時に一覧画面を表示
    );
  }
}
