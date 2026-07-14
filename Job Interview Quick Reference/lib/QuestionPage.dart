import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'AnswerPage.dart';
import 'InputPage.dart';
import 'QuestionModel.dart';

// 💡 演習結果（質問と計測タイム）を保存するクラス
class PracticeResult {
  final QuestionItem question;
  final int seconds;
  PracticeResult({required this.question, required this.seconds});
}

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

enum PracticeStatus { selecting, practicing, results }

class _PracticeBottomSheet extends StatefulWidget {
  final List<QuestionItem> items;
  const _PracticeBottomSheet({required this.items});
  @override
  State<_PracticeBottomSheet> createState() => _PracticeBottomSheetState();
}

class _PracticeBottomSheetState extends State<_PracticeBottomSheet> {
  final FlutterTts _flutterTts = FlutterTts();

  PracticeStatus _status = PracticeStatus.selecting;
  List<QuestionItem> _selectedQueue = [];
  List<PracticeResult> _results = []; // 💡 リザルト保存用
  bool _isRandomMode = false;
  bool _showAnswer = false;

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

  void _toggleSelection(QuestionItem item) {
    setState(() {
      if (_selectedQueue.contains(item)) {
        _selectedQueue.remove(item);
      } else {
        _selectedQueue.add(item);
      }
    });
  }

  void _startPracticeSession() {
    if (_selectedQueue.isEmpty) {
      final randomQuestion =
          widget.items[Random().nextInt(widget.items.length)];
      _selectedQueue = [randomQuestion];
    } else if (_isRandomMode) {
      _selectedQueue.shuffle();
    }

    setState(() {
      _status = PracticeStatus.practicing;
      _results.clear();
      _currentIndex = 0;
      _secondsElapsed = 0;
      _showAnswer = false;
    });
    _playCurrentQuestion();
  }

  void _playCurrentQuestion() async {
    _stopTimerOnly();
    setState(() {
      _isSpeaking = true;
      _secondsElapsed = 0;
      _showAnswer = false;
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
        if (mounted) setState(() => _secondsElapsed++);
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
    // 💡 計測結果を保存
    _results.add(
      PracticeResult(
        question: _selectedQueue[_currentIndex],
        seconds: _secondsElapsed,
      ),
    );

    if (_currentIndex < _selectedQueue.length - 1) {
      setState(() => _currentIndex++);
      _playCurrentQuestion();
    } else {
      _stopTimerOnly();
      setState(() => _status = PracticeStatus.results); // 💡 全問終了でリザルトへ
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
    final double sheetHeight = MediaQuery.of(context).size.height * 0.85;

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

          if (_status == PracticeStatus.selecting) ...[
            // ------------------- 【1. 選択画面】 -------------------
            const Text(
              "練習する質問を選んでください",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A375D),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedQueue.length == widget.items.length) {
                        _selectedQueue.clear();
                      } else {
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
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedQueue.contains(item);
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
                          isSelected
                              ? "${_selectedQueue.indexOf(item) + 1}"
                              : "",
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
          ] else if (_status == PracticeStatus.practicing) ...[
            // ------------------- 【2. 練習中画面】 -------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _stopTimerOnly();
                    setState(() => _status = PracticeStatus.selecting);
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
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 10),
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
                  if (_showAnswer)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _selectedQueue[_currentIndex].answer,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A375D),
                          ),
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
            const Spacer(),
            Text(
              _isSpeaking ? "面接官が質問中..." : "回答時間を計測中...",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: "monospace",
              ),
            ),
            const SizedBox(height: 12),
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
          ] else ...[
            // ------------------- 【3. リザルト画面（アドバイスなし）】 -------------------
            const Text(
              "模擬練習レポート",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF1A375D),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        result.question.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A375D),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTime(result.seconds),
                          style: const TextStyle(
                            fontFamily: "monospace",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _status = PracticeStatus.selecting;
                    _selectedQueue.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A375D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "練習を終了して戻る",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
