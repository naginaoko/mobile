import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'QuestionModel.dart';

class InputPage extends StatefulWidget {
  final QuestionItem? editingItem; // 編集時はデータが入る、追加時は空（null）になる

  const InputPage({super.key, this.editingItem});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _newCatController = TextEditingController(); // 新規カテゴリー入力用

  String _selectedCategory = ""; // 選択中のカテゴリーを保存する変数

  @override
  void initState() {
    super.initState();

    if (widget.editingItem != null) {
      _questionController.text = widget.editingItem!.question;
      _answerController.text = widget.editingItem!.answer;
      _selectedCategory = widget.editingItem!.category;
    } else {
      // 💡 新規追加時の初期値を「未分類」にします
      _selectedCategory = "未分類";
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _newCatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionProvider>(context);
    final isEditMode = widget.editingItem != null; // 編集モードかどうか

    // 安全対策：もし選択中のカテゴリーがリストになければ、先頭（未分類）にする
    if (_selectedCategory.isEmpty ||
        !provider.categories.contains(_selectedCategory)) {
      if (provider.categories.isNotEmpty) {
        _selectedCategory = provider.categories.first;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "質問の編集" : "質問の追加")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリー選択（ドロップダウン＆新規作成ボタン）
            const Text("カテゴリー", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                // プルダウン部分
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory.isNotEmpty
                        ? _selectedCategory
                        : null,
                    items: provider.categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // 新規追加ボタン
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("新しいカテゴリーを追加"),
                          content: TextField(
                            controller: _newCatController,
                            decoration: const InputDecoration(
                              hintText: "例：長所・短所",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _newCatController.clear();
                                Navigator.pop(context);
                              },
                              child: const Text("キャンセル"),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_newCatController.text.trim().isNotEmpty) {
                                  final newCat = _newCatController.text.trim();
                                  provider.addCategory(newCat);
                                  setState(() {
                                    _selectedCategory =
                                        newCat; // 追加したものを選択状態にする
                                  });
                                  _newCatController.clear();
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("追加"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A375D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("新規作成"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 質問入力欄
            const Text("質問", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(hintText: "質問を入力してください"),
            ),
            const SizedBox(height: 24),

            // 回答入力欄
            const Text("自分の回答", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _answerController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "回答を入力してください",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // 保存ボタン
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF1A375D),
              ),
              onPressed: () {
                if (isEditMode) {
                  provider.editQuestion(
                    widget.editingItem!.id,
                    _selectedCategory,
                    _questionController.text,
                    _answerController.text,
                  );
                } else {
                  provider.addQuestion(
                    _selectedCategory,
                    _questionController.text,
                    _answerController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text(
                "保存する",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
