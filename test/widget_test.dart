import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:interview_chatbot/main.dart';

void main() {
  testWidgets('App shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const InterviewChatApp());

    expect(find.text('面接対策チャットへようこそ'), findsOneWidget);
    expect(find.byIcon(Icons.work_outline), findsOneWidget);
  });
}
