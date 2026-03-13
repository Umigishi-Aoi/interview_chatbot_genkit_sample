import 'package:flutter/material.dart';

import 'chat_screen.dart';

void main() {
  runApp(const InterviewChatApp());
}

class InterviewChatApp extends StatelessWidget {
  const InterviewChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '面接対策チャット',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
