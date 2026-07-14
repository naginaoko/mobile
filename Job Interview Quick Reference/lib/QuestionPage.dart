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

class _PracticeBottomSheet extends StatefulWidget {
  final List<QuestionItem> items;
  const _PracticeBottomSheet({required this.items});

  @override
  State<_PracticeBottomSheet> createState() => _PracticeBottomSheetState();
}

class _PracticeBottomSheetState extends State<_PracticeBottomSheet> {
  final FlutterTts _flutterTts = FlutterTts();
  late QuestionItem _currentQuestion;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isSpeaking = false;
  bool _isTimerRunning = false;
  List<double> _waveHeights = List.generate(7, (index) => 15.0);

  @override
  void initState() {
    super.initState();
    _pickRandomQuestion();
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

  void _pickRandomQuestion() {
    _stopEverything();
    setState(() {
      _secondsLeft = 60;
      _currentQuestion = widget.items[Random().nextInt(widget.items.length)];
    });
  }

  void _startPractice() async {
    _stopEverything();
    setState(() {
      _isSpeaking = true;
      _secondsLeft = 60;
    });
    await _flutterTts.speak(_currentQuestion.question);
  }

  void _startTimer() {
    setState(() => _isTimerRunning = true);
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (timer.tick % 8 == 0) {
        if (_secondsLeft > 0) {
          if (mounted) setState(() => _secondsLeft--);
        } else {
          _stopEverything();
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

  void _stopEverything() {
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

  @override
  void dispose() {
    _stopEverything();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            "模擬面接練習モード",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentQuestion.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSpeaking
                ? "面接官が質問中..."
                : (_isTimerRunning ? "回答してください" : "準備ができたらスタート"),
            style: TextStyle(
              color: _isSpeaking ? Colors.orange : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "00:${_secondsLeft.toString().padLeft(2, '0')}",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: "monospace",
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
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
                        color: _isTimerRunning ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: (_isSpeaking || _isTimerRunning)
                    ? _stopEverything
                    : _startPractice,
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
                  (_isSpeaking || _isTimerRunning) ? "終了" : "練習開始",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickRandomQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.skip_next),
                label: const Text("次の質問"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
