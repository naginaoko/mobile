import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 質問と回答のデータを表すクラス
class QuestionItem {
  final String id;
  String category;
  String question;
  String answer;
  String date;

  QuestionItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
      'date': date,
    };
  }

  factory QuestionItem.fromMap(Map<String, dynamic> map) {
    return QuestionItem(
      id: map['id'],
      category: map['category'],
      question: map['question'],
      answer: map['answer'],
      date: map['date'],
    );
  }
}

// データの「追加・編集・削除・保存」を一括管理するクラス
class QuestionProvider extends ChangeNotifier {
  List<QuestionItem> _items = [];
  List<QuestionItem> get items => _items;

  // ーーー ★【ここを拡張】自由に追加できるカテゴリーリスト ーーー
  // 最初は基本の3つを用意（「すべて」はシステム側で扱うためここには含めません）
  List<String> _categories = ["自己PR", "志望動機", "逆質問"];
  List<String> get categories => _categories; // 画面から読み取るためのゲッター

  String _selectedCategory = 'すべて';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // ★新しいカテゴリーをユーザーが追加する関数
  Future<void> addCategory(String newCategory) async {
    final trimmed = newCategory.trim();
    if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
      _categories.add(trimmed);
      notifyListeners();
      await saveCategories(); // カテゴリーリストもスマホに保存する
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<QuestionItem> get filteredItems {
    List<QuestionItem> list = _items;
    if (_selectedCategory != 'すべて') {
      list = _items
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (item) => item.question.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    return list;
  }

  // ストレージ用のキー
  static const String _storageKey = 'saved_questions';
  static const String _categoryKey = 'saved_categories'; // ★カテゴリー保存用のキー

  QuestionProvider() {
    loadData(); // 起動時に一括読み込み
  }

  // カテゴリーだけの保存処理
  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey, _categories);
  }

  // 質問データの保存処理
  Future<void> saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mappedList = _items
        .map((item) => item.toMap())
        .toList();
    String jsonString = jsonEncode(mappedList);
    await prefs.setString(_storageKey, jsonString);
  }

  // ★質問とカテゴリーを両方とも読み込む関数に統合
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. カテゴリーの読み込み
    List<String>? savedCats = prefs.getStringList(_categoryKey);
    if (savedCats != null) {
      _categories = savedCats;
    }

    // 2. 質問データの読み込み
    String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      // 初期データ
      _items = [
        QuestionItem(
          id: '1',
          category: "志望動機",
          question: "弊社を志望する理由は何ですか？",
          answer: "御社の「ユーザーの課題を技術で解決する」という理念に深く共感いたしました...",
          date: "2026/05/20",
        ),
        QuestionItem(
          id: '2',
          category: "自己PR",
          question: "3分以内で自己PRしてください。",
          answer: "私の強みは、問題に対して粘り強く原因を突き止め、解決まで行動できる点です...",
          date: "2026/05/18",
        ),
      ];
      await saveQuestions();
      await saveCategories();
      notifyListeners();
      return;
    }

    List<dynamic> decodedList = jsonDecode(jsonString);
    _items = decodedList.map((map) => QuestionItem.fromMap(map)).toList();
    notifyListeners();
  }

  void addQuestion(String category, String question, String answer) async {
    final newItem = QuestionItem(
      id: DateTime.now().toString(),
      category: category,
      question: question,
      answer: answer,
      date:
          "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
    );
    _items.add(newItem);
    notifyListeners();
    await saveQuestions();
  }

  void editQuestion(
    String id,
    String newCategory,
    String newQuestion,
    String newAnswer,
  ) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].category = newCategory;
      _items[index].question = newQuestion;
      _items[index].answer = newAnswer;
      _items[index].date =
          "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}";
      notifyListeners();
      await saveQuestions();
    }
  }

  void deleteQuestion(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await saveQuestions();
  }
}
