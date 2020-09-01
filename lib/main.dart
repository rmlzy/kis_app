import 'package:flutter/material.dart';

import 'pages/HomePage.dart';
import 'pages/CategoryPage.dart';
import 'pages/LoginPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hello Flutter',
      theme: new ThemeData(primarySwatch: Colors.blueGrey),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        '/login': (context) => new LoginPage(),
        '/category': (context) => new CategoryPage()
      },
    );
  }
}
