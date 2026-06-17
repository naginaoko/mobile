import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // データを読み取るために必要
import 'AnswerPage.dart';
import 'InputPage.dart'; // 入力画面を開くために必要
import 'QuestionModel.dart'; // データの型を使うために必要

class Questionpage extends StatelessWidget {
  const Questionpage({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerからデータ一覧と、選択中のカテゴリー情報を受け取る
    final provider = Provider.of<QuestionProvider>(context);

    // 全件(allItems)ではなく、新しく作った「絞り込み済みのリスト」を使うように変更
    final displayItems = provider.filteredItems;

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
          // カテゴリータブ部分
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // 文字が入力されるたびに、リアルタイムでProviderにキーワードを伝える
                Provider.of<QuestionProvider>(
                  context,
                  listen: false,
                ).setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: "質問を検索...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A375D)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // カテゴリータブ部分
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // ① まずは固定で「すべて」のタグを置く
                  _buildCategoryTag(
                    context,
                    "すべて",
                    isSelected: provider.selectedCategory == "すべて",
                  ),

                  // ② 【ここを変更！】Providerにあるカテゴリーリストから自動で並べる
                  ...provider.categories.map((cat) {
                    return _buildCategoryTag(
                      context,
                      cat,
                      isSelected: provider.selectedCategory == cat,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // 質問リスト部分
          Expanded(
            child:
                displayItems
                    .isEmpty // 絞り込んだ結果、空っぽの場合の処理
                ? const Center(child: Text("このカテゴリーの質問はまだありません。"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayItems.length, // 絞り込まれたデータの数だけループ
                    itemBuilder: (context, index) {
                      final item = displayItems[index]; // 1つ分のデータを取り出す
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

  // カテゴリータグの部品（タップできるように GestureDetector で包み、context を追加）
  Widget _buildCategoryTag(
    BuildContext context,
    String label, {
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        // タップされたら、Providerに「このカテゴリーが選ばれたよ！」と伝えます
        onTap: () {
          Provider.of<QuestionProvider>(
            context,
            listen: false,
          ).setCategory(label);
        },
        child: Container(
          // タップの反応範囲を広げるための設定
          color: Colors.transparent,
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
        ),
      ),
    );
  }

  // 質問カードの部品
  Widget _buildQuestionCard(BuildContext context, QuestionItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnswerPage(itemId: item.id),
            ),
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
                      item.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.question,
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
