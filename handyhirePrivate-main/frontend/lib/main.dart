import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const HandyHireApp());
}

class HandyHireApp extends StatelessWidget {
  const HandyHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handy Hire',
      theme: ThemeData(
        primaryColor: const Color(0xFF0B1E3F),
        textTheme: ThemeData.light().textTheme,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
