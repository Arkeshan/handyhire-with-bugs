// Basic smoke test for HandyHire. The original template test referenced a
// counter widget that never existed in this app and would fail on CI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handyhire/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const HandyHireApp());
    // Let the splash screen settle.
    await tester.pump(const Duration(seconds: 3));

    // Login screen is the initial route — look for any Text widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
