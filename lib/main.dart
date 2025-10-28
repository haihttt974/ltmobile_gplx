import 'package:flutter/material.dart';
import 'Views/Auth/splash_view.dart';
import 'Views/Tip/tips_memory_screen.dart';

void main() {
  runApp(const GplxApp());
}

class GplxApp extends StatelessWidget {
  const GplxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ôn tập GPLX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TipsMemoryScreen(),
    );
  }
}
