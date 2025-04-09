import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(EmpowerHerApp());
}

class EmpowerHerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: WelcomeScreen(),
    );
  }
}
