import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connect_b/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ConnectBApp(hasSession: false));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
