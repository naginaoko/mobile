import 'package:flutter/material.dart';

class Thirdpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ページ(3)")),
      body: Center(
        child: TextButton(
          child: Text("最初のページに戻る"),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            /*// （1） 指定した画面に遷移する
            Navigator.push(
              context,
              MaterialPageRoute(
                // （2） 実際に表示するページ(ウィジェット)を指定する
                builder: (context) => HomePage(),
              ),
            );*/
          },
        ),
      ),
    );
  }
}
