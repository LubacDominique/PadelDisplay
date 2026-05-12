// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:padel_mobile_app/main.dart';
import 'package:padel_mobile_app/services/ble_service.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BLEService(),
        child: const PadelApp(),
      ),
    );

    // Verify that we have the home screen
    expect(find.text('Padel Display'), findsOneWidget);
    expect(find.text('Non connecté au tableau'), findsOneWidget);
    expect(find.text('Rechercher tableau'), findsOneWidget);
  });
}
