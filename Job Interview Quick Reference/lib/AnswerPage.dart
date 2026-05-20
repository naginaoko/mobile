import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'InputPage.dart';
import 'QuestionModel.dart';

class AnswerPage extends StatelessWidget {
  final QuestionItem item; // 前の画面から渡されたデータを受け取る変数

  // コンストラクタでデータを受け取ることを必須（required）にする
  const AnswerPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 削除機能を使うためにプロバイダーを用意
    final provider = Provider.of<QuestionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "回答確認",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A375D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A375D)),
        actions: [
          // 【編集ボタン】現在のデータを引き渡して入力画面を「編集モード」で開く
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InputPage(editingItem: item),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          // 【削除ボタン】プロバイダーの削除命令を呼び出す
          IconButton(
            onPressed: () {
              // 確認ダイアログを表示する
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("削除の確認"),
                  content: const Text("この質問を削除してもよろしいですか？"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("キャンセル"),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.deleteQuestion(item.id); // データを削除
                        Navigator.pop(ctx); // ダイアログを閉じる
                        Navigator.pop(context); // 詳細画面も閉じて一覧に戻る
                      },
                      child: const Text(
                        "削除",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.category, // 受け取ったカテゴリーを表示
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "質問",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.question, // 受け取った質問を表示
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A375D),
                height: 1.3,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            ),
            const Text(
              "自分の回答",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.answer, // 受け取った回答を表示
              style: const TextStyle(
                fontSize: 17,
                height: 1.8,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Color(0xFF1A375D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "一覧に戻る",
              style: TextStyle(
                color: Color(0xFF1A375D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
