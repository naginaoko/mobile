import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // データを読み取るために必要
import 'AnswerPage.dart';
import 'InputPage.dart'; // 入力画面を開くために必要
import 'QuestionModel.dart'; // データの型を使うために必要

class Questionpage extends StatelessWidget {
  const Questionpage({super.key});

  @override
  Widget build(BuildContext context) {
    // 【最重要】Providerから最新のデータ一覧を受け取る
    final provider = Provider.of<QuestionProvider>(context);
    final allItems = provider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "面接クイックリファレンス",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A375D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Color(0xFF1A375D)),
          ),
        ],
      ),
      body: Column(
        children: [
          // カテゴリータブ部分（見た目はそのまま）
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryTag("すべて", isSelected: true),
                  _buildCategoryTag("自己PR"),
                  _buildCategoryTag("志望動機"),
                  _buildCategoryTag("逆質問"),
                ],
              ),
            ),
          ),

          // 質問リスト部分
          Expanded(
            child: allItems.isEmpty
                ? const Center(child: Text("質問がありません。右下のボタンから追加してください。"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allItems.length, // データの数だけループしてカードを作る
                    itemBuilder: (context, index) {
                      final item = allItems[index]; // 1つ分のデータを取り出す
                      return _buildQuestionCard(context, item);
                    },
                  ),
          ),
        ],
      ),
      // 右下の「＋」ボタンを押したら、追加モードで入力画面を開く
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputPage()),
          );
        },
        backgroundColor: const Color(0xFF1A375D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // カテゴリータグの部品（見た目はそのまま）
  Widget _buildCategoryTag(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  // 質問カードの部品（引数を本物のデータ型に変更）
  Widget _buildQuestionCard(BuildContext context, QuestionItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 詳細画面へ行くときに、タップされたデータを丸ごと引き渡す！
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnswerPage(item: item)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category, // 本物のカテゴリーを表示
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    item.date, // 本物の日付を表示
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.question, // 本物の質問文を表示
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A375D),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
