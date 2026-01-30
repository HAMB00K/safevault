// SafeVault Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pjaxd/main.dart';

void main() {
  testWidgets('SafeVault app initializes correctly', (WidgetTester tester) async {
    // Build SafeVault app
    await tester.pumpWidget(const ProviderScope(child: SafeVaultApp()));
    await tester.pumpAndSettle();

    // Verify the app starts (this is a basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Splash screen displays logo', (WidgetTester tester) async {
    // Build SafeVault app
    await tester.pumpWidget(const ProviderScope(child: SafeVaultApp()));
    
    // Verify splash screen elements
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.text('SafeVault'), findsOneWidget);
  });
}
