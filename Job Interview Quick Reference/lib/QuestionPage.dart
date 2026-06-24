import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // データを読み取るために必要
import 'AnswerPage.dart';
import 'InputPage.dart'; // 入力画面を開くために必要
import 'QuestionModel.dart'; // データの型を使うために必要

class Questionpage extends StatelessWidget {
  const Questionpage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionProvider>(context);
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
      ),
      body: Column(
        children: [
          // リアルタイム検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                provider.setSearchQuery(value);
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

          // カテゴリータブ部分（長押しで削除可能に拡張）
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // ① 「すべて」タグ（削除不可）
                  _buildCategoryTag(
                    context,
                    "すべて",
                    isSelected: provider.selectedCategory == "すべて",
                    canDelete: false,
                  ),

                  // ② ユーザー自作カテゴリーリスト（「未分類」以外は長押し削除可能）
                  ...provider.categories.map((cat) {
                    return _buildCategoryTag(
                      context,
                      cat,
                      isSelected: provider.selectedCategory == cat,
                      canDelete: cat != "未分類", // 未分類は削除不可にする
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // 質問リスト部分
          Expanded(
            child: displayItems.isEmpty
                ? const Center(child: Text("該当する質問がありません。"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      return _buildQuestionCard(context, item);
                    },
                  ),
          ),
        ],
      ),
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

  // カテゴリータグの部品（長押し削除イベントに対応）
  Widget _buildCategoryTag(
    BuildContext context,
    String label, {
    bool isSelected = false,
    bool canDelete = false,
  }) {
    final provider = Provider.of<QuestionProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          provider.setCategory(label);
        },
        // 💡 タブの長押しで削除ダイアログを表示
        onLongPress: () {
          if (!canDelete) return; // 削除不可のものは何もしない

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("「$label」を削除しますか？"),
                content: const Text("このカテゴリーを削除しても、中の質問は消えずに「未分類」へ移動します。"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("キャンセル"),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.deleteCategory(label);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("「$label」カテゴリーを削除しました。質問は未分類に移動しました。"),
                        ),
                      );
                    },
                    child: const Text(
                      "削除",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
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
