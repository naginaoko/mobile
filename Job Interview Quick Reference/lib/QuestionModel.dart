import 'package:flutter/material.dart';

// 1. 質問と回答のデータを表すクラス
class QuestionItem {
  final String id; // データを区別するためのID
  String category; // カテゴリー（志望動機、自己PRなど）
  String question; // 質問内容
  String answer; // 回答内容
  String date; // 登録・更新日

  // コンストラクタ（この形でデータを作りますというルール）
  QuestionItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.date,
  });
}

// 2. データの「追加・編集・削除」を一括管理するクラス
class QuestionProvider extends ChangeNotifier {
  // アプリが起動した時の初期データ（ダミーデータ）
  final List<QuestionItem> _items = [
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

  // 外部の画面からデータ一覧を読み取るための通り道
  List<QuestionItem> get items => _items;

  // 【機能：追加】新しい質問を追加する
  void addQuestion(String category, String question, String answer) {
    final newItem = QuestionItem(
      id: DateTime.now().toString(), // 現在時刻をそのままユニークなIDにする
      category: category,
      question: question,
      answer: answer,
      date:
          "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
    );
    _items.add(newItem);

    // 【超重要】「データが変わったから画面を再描画して！」とアプリ全体に通知する
    notifyListeners();
  }

  // 【機能：編集】既存の質問を書き換える
  void editQuestion(
    String id,
    String newCategory,
    String newQuestion,
    String newAnswer,
  ) {
    // IDが一致するデータを一覧から探す
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].category = newCategory;
      _items[index].question = newQuestion;
      _items[index].answer = newAnswer;
      _items[index].date =
          "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}";

      notifyListeners(); // 画面を更新
    }
  }

  // 【機能：削除】質問を削除する
  void deleteQuestion(String id) {
    _items.removeWhere((item) => item.id == id);

    notifyListeners(); // 画面を更新
  }
}
