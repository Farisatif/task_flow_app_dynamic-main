import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow_app/main.dart';
import 'package:task_flow_app/core/database/database_provider.dart';

void main() {
  testWidgets('Task Flow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      DatabaseBootstrap(
        builder: (context) => const TaskFlowApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
