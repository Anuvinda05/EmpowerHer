import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';


void main() {
  runApp(EmpowerHerApp());
}

class EmpowerHerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/welcome', // Start from the Welcome Screen
      routes: {
        '/welcome': (context) => WelcomeScreen(), // Welcome Page
        '/register': (context) => RegisterScreen(), // Register Page
        '/login': (context) => LoginScreen(),// Login Page
        '/home': (context) => HomeScreen(),// home Page
      },
    );
  }
}
