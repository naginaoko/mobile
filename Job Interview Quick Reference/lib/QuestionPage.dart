import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 💡 読み上げ用パッケージ
import 'AnswerPage.dart';
import 'InputPage.dart';
import 'QuestionModel.dart';

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                if (provider.items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("まずは質問を1件以上登録してください。")),
                  );
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      _PracticeBottomSheet(items: provider.items),
                );
              },
              icon: const Icon(
                Icons.record_voice_over,
                color: Colors.blue,
                size: 24,
              ),
              label: const Text(
                "模擬練習",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => provider.setSearchQuery(value),
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryTag(
                    context,
                    "すべて",
                    isSelected: provider.selectedCategory == "すべて",
                    canDelete: false,
                  ),
                  ...provider.categories.map((cat) {
                    return _buildCategoryTag(
                      context,
                      cat,
                      isSelected: provider.selectedCategory == cat,
                      canDelete: cat != "未分類",
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Expanded(
            child: displayItems.isEmpty
                ? const Center(child: Text("該当する質問がありません。"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) =>
                        _buildQuestionCard(context, displayItems[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InputPage()),
        ),
        backgroundColor: const Color(0xFF1A375D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryTag(
    BuildContext context,
    String label, {
    bool isSelected = false,
    bool canDelete = false,
  }) {
    final provider = Provider.of<QuestionProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => provider.setCategory(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              if (canDelete && isSelected) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showDeleteDialog(context, provider, label),
                  child: const Icon(Icons.close, size: 14, color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    QuestionProvider provider,
    String label,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("「$label」を削除しますか？"),
        content: const Text("中の質問は「未分類」へ移動します。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("キャンセル"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCategory(label);
              Navigator.pop(context);
            },
            child: const Text("削除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnswerPage(itemId: item.id)),
        ),
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

// 💡 順番選択 ✕ 一括全選択 ✕ クイック演習 ✕ 計測タイマー ✕ 回答表示 模擬練習
class _PracticeBottomSheet extends StatefulWidget {
  final List<QuestionItem> items;
  const _PracticeBottomSheet({required this.items});

  @override
  State<_PracticeBottomSheet> createState() => _PracticeBottomSheetState();
}

class _PracticeBottomSheetState extends State<_PracticeBottomSheet> {
  final FlutterTts _flutterTts = FlutterTts();

  // 練習ステート
  bool _hasStarted = false; // 練習中フラグ
  List<QuestionItem> _selectedQueue = []; // タップした順番に格納されるキュー
  bool _isRandomMode = false; // ランダムシャッフルモードON/OFF
  bool _showAnswer = false; // 💡 回答の表示・非表示フラグ

  int _currentIndex = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isSpeaking = false;
  bool _isTimerRunning = false;
  List<double> _waveHeights = List.generate(7, (index) => 15.0);

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  void _setupTts() async {
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _startTimer();
        });
      }
    });
  }

  // 質問のタップ選択時の挙動（順番管理）
  void _toggleSelection(QuestionItem item) {
    setState(() {
      if (_selectedQueue.contains(item)) {
        _selectedQueue.remove(item);
      } else {
        _selectedQueue.add(item);
      }
    });
  }

  // 演習開始処理
  void _startPracticeSession() {
    if (_selectedQueue.isEmpty) {
      // 💡 何も選択されていない場合は「クイック演習（ランダム1問）」として動作
      final randomQuestion =
          widget.items[Random().nextInt(widget.items.length)];
      _selectedQueue = [randomQuestion];
    } else if (_isRandomMode) {
      // 💡 ランダム出題モードがONなら、選んだキューをシャッフルする
      _selectedQueue.shuffle();
    }

    setState(() {
      _hasStarted = true;
      _currentIndex = 0;
      _secondsElapsed = 0;
      _showAnswer = false; // 初期状態は非表示
    });
    _playCurrentQuestion();
  }

  void _playCurrentQuestion() async {
    _stopTimerOnly();
    setState(() {
      _isSpeaking = true;
      _secondsElapsed = 0;
      _showAnswer = false; // 💡 新しい質問に切り替わるときは回答表示をリセット
    });
    await _flutterTts.speak(_selectedQueue[_currentIndex].question);
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _secondsElapsed = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (timer.tick % 8 == 0) {
        // 💡 約1秒ごと（120ms * 8 = 960ms ≒ 1秒）
        if (mounted) {
          setState(() {
            _secondsElapsed++;
          });
        }
      }
      if (mounted) {
        setState(() {
          _waveHeights = List.generate(
            7,
            (index) => 10.0 + Random().nextDouble() * 50.0,
          );
        });
      }
    });
  }

  void _stopTimerOnly() {
    _timer?.cancel();
    _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _isTimerRunning = false;
        _waveHeights = List.generate(7, (index) => 15.0);
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _selectedQueue.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playCurrentQuestion();
    } else {
      // すべての質問をやりきった場合
      _stopTimerOnly();
      setState(() {
        _hasStarted = false;
        _selectedQueue.clear(); // 選択クリア
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 選択したすべての模擬練習が完了しました！お疲れ様でした！"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズに応じて高さを動的調整（キーボード考慮）
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 💡 ステートによって中身を切り替え
          if (!_hasStarted) ...[
            // ------------------- 【選択画面】 -------------------
            const Text(
              "練習する質問を選んでください",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A375D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "タップした順番に出題されます（未選択ならランダム1問）",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // 💡 「すべて選択」ボタン ✕ 「ランダムトグル」
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // すべて選択/クリアボタン
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedQueue.length == widget.items.length) {
                        _selectedQueue.clear(); // すべてクリア
                      } else {
                        // 順番通りにすべて格納
                        _selectedQueue = List.from(widget.items);
                      }
                    });
                  },
                  icon: Icon(
                    _selectedQueue.length == widget.items.length
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(
                    _selectedQueue.length == widget.items.length
                        ? "選択解除"
                        : "すべて選択",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // ランダム切り替え
                Row(
                  children: [
                    const Text("ランダム出題", style: TextStyle(fontSize: 13)),
                    Switch(
                      value: _isRandomMode,
                      onChanged: (val) => setState(() => _isRandomMode = val),
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // 質問の複数選択リスト
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedQueue.contains(item);
                  final selectedIndex = _selectedQueue.indexOf(item);

                  return Card(
                    elevation: 0,
                    color: isSelected
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _toggleSelection(item),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected
                            ? Colors.blue
                            : Colors.grey[300],
                        child: Text(
                          isSelected ? "${selectedIndex + 1}" : "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item.question,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        item.category,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _startPracticeSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A375D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedQueue.isEmpty
                      ? "クイック練習を開始"
                      : "選択した練習を開始 (${_selectedQueue.length}件)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            // ------------------- 【練習実行画面】 -------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _stopTimerOnly();
                    setState(() => _hasStarted = false);
                  },
                ),
                Text(
                  "練習中: ${_currentIndex + 1} / ${_selectedQueue.length}問目",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A375D),
                  ),
                ),
                const SizedBox(width: 48), // バランス用
              ],
            ),
            const SizedBox(height: 10),

            // 質問テキスト ✕ 💡 回答切り替え機能
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _selectedQueue[_currentIndex].question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 💡 目のマークを押すと、登録された回答がチラッと見れる！
                  if (_showAnswer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        _selectedQueue[_currentIndex].answer,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A375D),
                        ),
                      ),
                    ),

                  TextButton.icon(
                    onPressed: () => setState(() => _showAnswer = !_showAnswer),
                    icon: Icon(
                      _showAnswer ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(
                      _showAnswer ? "回答を隠す" : "回答を確認",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _isSpeaking
                  ? "面接官が質問中..."
                  : (_isTimerRunning ? "回答にかかった時間を計測中..." : "準備ができたらスタート"),
              style: TextStyle(
                color: _isSpeaking ? Colors.orange : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 計測ストップウォッチ
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: "monospace",
              ),
            ),
            const SizedBox(height: 8),

            // 波形
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _waveHeights
                    .map(
                      (h) => AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: h,
                        decoration: BoxDecoration(
                          color: _isTimerRunning
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Spacer(),

            // コントロールボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: (_isSpeaking || _isTimerRunning)
                      ? _stopTimerOnly
                      : _playCurrentQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isSpeaking || _isTimerRunning)
                        ? Colors.red
                        : const Color(0xFF1A375D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(
                    (_isSpeaking || _isTimerRunning)
                        ? Icons.stop
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    (_isSpeaking || _isTimerRunning) ? "停止" : "もう一度聞く",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _nextQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(
                    _currentIndex == _selectedQueue.length - 1
                        ? Icons.check
                        : Icons.skip_next,
                  ),
                  label: Text(
                    _currentIndex == _selectedQueue.length - 1
                        ? "練習完了"
                        : "次の質問へ",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
