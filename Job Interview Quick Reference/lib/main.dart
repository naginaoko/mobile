import 'package:flutter/material.dart';
import 'package:sample/MainPageWidget.dart';
//import 'package:sample/HomePage.dart';
//import '/list/CouponListView.dart';
//import 'FirstPage.dart';
//import 'SecondPage.dart';
//import 'ThirdPage.dart';
//import 'package:sample/list/CouponListView.dart';
import 'MainPageWidget.dart';
import 'QuestionPage.dart';
import 'AnswerPage.dart';

void main() {
  runApp(const MyApp());
  //runApp(HomePage());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //ListViewのためのダミーメソッド
  //void dummyDetail() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '面接クイックリファレンス',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: Questionpage(),

      /*initialRoute: '/home',
      routes: {
        '/home': (context) => Questionpage(),
        '/first': (content) => AnswerPage(),
        '/second': (content) => Secondpage(),
        '/third': (content) => Thirdpage(),
      },*/

      //ListViewの導入テスト
      //home: CouponListView(dummyDetail),
      //
      //home: MainPageWidget(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
