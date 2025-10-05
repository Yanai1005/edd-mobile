import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:allergy_guard/main.dart';
import 'package:allergy_guard/providers/menu_scan_provider.dart';

void main() {
  testWidgets('App should start and display AllergyGuard title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that app title is displayed
    expect(find.text('AllergyGuard'), findsWidgets);
  });

  testWidgets('HomeScreen should display main UI elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MenuScanProvider(),
        child: const MaterialApp(home: MyApp()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main elements exist
    expect(find.text('AllergyGuard'), findsWidgets);
    expect(find.text('海外のレストランメニューを撮影して\nアレルギー情報をチェック'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  testWidgets('HomeScreen should show warning when no allergies are set',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MenuScanProvider(),
        child: const MaterialApp(home: MyApp()),
      ),
    );

    await tester.pumpAndSettle();

    // Should show allergy warning
    expect(find.text('アレルギー情報が未設定です'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('Settings button should be visible', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find settings icon in app bar
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
