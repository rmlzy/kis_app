import 'package:flutter/material.dart';

import 'pages/HomePage.dart';
import 'pages/LoginPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hello Flutter',
      theme: new ThemeData(primarySwatch: Colors.teal),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext ctx) => new LoginPage(),
      },
    );
  }
}
