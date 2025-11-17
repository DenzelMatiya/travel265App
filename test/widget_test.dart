// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel265/main.dart';

void main() {
  testWidgets('Travel265 app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const Travel265App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

}