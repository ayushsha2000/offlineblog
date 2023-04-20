import 'package:flutter/material.dart';
import 'package:offlineblog/screens/list_blog_item.dart';

void main() {
  runApp(MyApp());
}

// The root widget of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlogItemListScreen(),
    );
  }
}
