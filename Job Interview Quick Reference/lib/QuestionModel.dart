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

  List<String> _categories = ["未分類", "自己PR", "志望動機", "逆質問"];
  List<String> get categories => _categories;

  String _selectedCategory = 'すべて';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // 新しいカテゴリーをユーザーが追加する関数
  Future<void> addCategory(String newCategory) async {
    final trimmed = newCategory.trim();
    if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
      _categories.add(trimmed);
      notifyListeners();
      await saveCategories();
    }
  }

  // 💡 【新機能】カテゴリーの安全削除（パターンB：中の質問は「未分類」へお引越し）
  Future<void> deleteCategory(String categoryName) async {
    // 安全対策：「未分類」そのものは削除できないようにする
    if (categoryName == "未分類") return;

    if (_categories.contains(categoryName)) {
      // 1. カテゴリーリストから削除
      _categories.remove(categoryName);

      // 2. ★該当するカテゴリーだった質問をすべて「未分類」に書き換える
      for (var item in _items) {
        if (item.category == categoryName) {
          item.category = "未分類";
        }
      }

      // 3. もし削除したカテゴリーを今画面で選択中だった場合、選択を「すべて」に戻す
      if (_selectedCategory == categoryName) {
        _selectedCategory = 'すべて';
      }

      notifyListeners();
      await saveCategories(); // カテゴリー状態を保存
      await saveQuestions(); // 質問のお引越し状態を保存
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

  static const String _storageKey = 'saved_questions';
  static const String _categoryKey = 'saved_categories';

  QuestionProvider() {
    loadData();
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey, _categories);
  }

  Future<void> saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mappedList = _items
        .map((item) => item.toMap())
        .toList();
    String jsonString = jsonEncode(mappedList);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? savedCats = prefs.getStringList(_categoryKey);
    if (savedCats != null) {
      _categories = savedCats;
      if (!_categories.contains("未分類")) {
        _categories.insert(0, "未分類");
      }
    }

    String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
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
