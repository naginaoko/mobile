import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'InputPage.dart';
import 'QuestionModel.dart';

class AnswerPage extends StatelessWidget {
  // データを特定するためのidを受け取る
  final String itemId;

  const AnswerPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    // Providerから最新のデータ一覧をリアルタイムに監視
    final provider = Provider.of<QuestionProvider>(context);

    // 全データの中から、前の画面から渡されたidと一致する最新の1件を探し出す
    // もし削除された直後などで見つからない場合は、仮の空データを入れる
    final item = provider.items.firstWhere(
      (element) => element.id == itemId,
      orElse: () => QuestionItem(
        id: '',
        category: '',
        question: '',
        answer: '',
        date: '',
      ),
    );

    // もしデータが空（削除された後）なら、何も描画せず一瞬で画面を閉じる
    if (item.id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          // 【編集ボタン】
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
          // 【削除ボタン】
          IconButton(
            onPressed: () {
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
                        // listen: false をつけて、ボタンを押した瞬間にだけ削除を実行
                        Provider.of<QuestionProvider>(
                          context,
                          listen: false,
                        ).deleteQuestion(item.id);
                        Navigator.pop(ctx); // ダイアログを閉じる
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
                item.category,
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
              item.question,
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
              item.answer,
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
