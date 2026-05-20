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
  // 文字入力を監視・制御するためのコントローラー
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedCategory = "志望動機"; // 初期値

  @override
  void initState() {
    super.override(context);
    // もし「編集モード」で画面が開かれたら、最初から元の文字を入力欄に入れておく
    if (widget.editingItem != null) {
      _questionController.text = widget.editingItem!.question;
      _answerController.text = widget.editingItem!.answer;
      _selectedCategory = widget.editingItem!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.editingItem != null; // 編集モードかどうか

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "質問の編集" : "質問の追加")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリー選択（ドロップダウン）
            const Text("カテゴリー", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ["志望動機", "自己PR", "逆質問"].map((String value) {
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
              maxLines: 5, // 複数行入力できるようにする
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
                final provider = Provider.of<QuestionProvider>(
                  context,
                  listen: false,
                );

                if (isEditMode) {
                  // 編集保存
                  provider.editQuestion(
                    widget.editingItem!.id,
                    _selectedCategory,
                    _questionController.text,
                    _answerController.text,
                  );
                } else {
                  // 新規追加
                  provider.addQuestion(
                    _selectedCategory,
                    _questionController.text,
                    _answerController.text,
                  );
                }
                Navigator.pop(context); // 入力画面を閉じる
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
