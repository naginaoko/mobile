import 'dart:convert'; // 1. JSONの変換（文字とリストの行き来）に必要です
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 2. 保存ツール

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

  // データを「保存用」のマップ型（連想配列）に変換する関数
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
      'date': date,
    };
  }

  // 保存されていたマップ型から、元の「QuestionItem型」に復元する関数
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
  // 最初は空っぽのリストにしておき、起動時にスマホから読み込み
  List<QuestionItem> _items = [];

  List<QuestionItem> get items => _items;

  // ーーー 🔍 【ここから追加】検索用の変数 ーーー
  String _selectedCategory = 'すべて';
  String _searchQuery = ''; // 検索キーワードを保存する変数

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery; // 外部からキーワードを読み取るゲッター

  // タブが切り替わったときに、選択中のカテゴリーを更新する関数
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners(); // 画面に「切り替わったから再描画してね！」と通知
  }

  // ★【検索対応に書き換え】カテゴリーと検索キーワードの2重フィルターをかける
  List<QuestionItem> get filteredItems {
    // 1. まずはカテゴリーで絞り込む
    List<QuestionItem> list = _items;
    if (_selectedCategory != 'すべて') {
      list = _items
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    // 2. もし検索キーワードが入っていれば、さらにその文字が含まれる質問だけを残す
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

  // 検索キーワードが入力されたときに呼び出す関数
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // 文字が変わるたびに画面をリアルタイムに再描画
  }
  // ーーー 🔍 【ここまで追加】 ーーー

  // 保存するときに使うスマホ内部の「引き出しの名前（キー）」
  static const String _storageKey = 'saved_questions';

  // コンストラクタ：このProviderが立ち上がった瞬間に、自動でスマホからデータを読み込み
  QuestionProvider() {
    loadQuestions();
  }

  // 【機能：保存】現在のリストをスマホのローカルストレージに書き込む
  Future<void> saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. リストの中身をすべて Map型 に変換する
    List<Map<String, dynamic>> mappedList = _items
        .map((item) => item.toMap())
        .toList();

    // 2. Map型のリストを、1本の長いJSON文字列（テキスト）に変換する
    String jsonString = jsonEncode(mappedList);

    // 3. スマホの引き出しに保存する
    await prefs.setString(_storageKey, jsonString);
  }

  // 【機能：読み込み】スマホからデータを復元する
  Future<void> loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_storageKey);

    // もしスマホに過去の保存データが何もなければ、最初の2件（初期データ）をプレゼントする
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
      await saveQuestions(); // 初期データを保存しておく
      notifyListeners();
      return;
    }

    // 保存されたテキストがある場合は、解凍して元のQuestionItemのリストに戻す
    List<dynamic> decodedList = jsonDecode(jsonString);
    _items = decodedList.map((map) => QuestionItem.fromMap(map)).toList();

    notifyListeners(); // 画面にデータが読み込めたと通知して再描画
  }

  // 【機能：追加】
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
    await saveQuestions(); // データが変わったのでスマホに即座に保存
  }

  // 【機能：編集】
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
      await saveQuestions(); // データが変わったのでスマホに即座に保存
    }
  }

  // 【機能：削除】
  void deleteQuestion(String id) async {
    _items.removeWhere((item) => item.id == id);

    notifyListeners();
    await saveQuestions(); // データが変わったのでスマホに即座に保存
  }
}
