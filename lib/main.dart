import 'package:flutter/material.dart';
import 'items.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final Color primCol = Colors.white;
  final Color accCol = Colors.black;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'IP Calculator',
    theme: ThemeData(
        primaryColor: primCol,
        accentColor: accCol,
    ),
    home: SomePage(),
    );
  }
}