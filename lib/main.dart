import 'package:flutter/material.dart';

import 'package:terminal/view/homeView.dart';

void main() {
  runApp(const TerminalApp());
}

class TerminalApp extends StatelessWidget {
  const TerminalApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Terminal',
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
