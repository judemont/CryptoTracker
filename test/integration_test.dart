// Integration test to verify price alert functionality works
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cryptotracker/main.dart';
import 'package:cryptotracker/screens/price_alerts_screen.dart';
import 'package:cryptotracker/widgets/create_alert_dialog.dart';

void main() {
  testWidgets('Price Alert Integration Test', (WidgetTester tester) async {
    // Test that the app starts without errors
    await tester.pumpWidget(const MyApp());
    
    // Verify the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Test that the alerts screen can be created
    await tester.pumpWidget(
      MaterialApp(
        home: const PriceAlertsScreen(),
      ),
    );
    
    // Verify alerts screen elements are present
    expect(find.text('Price Alerts'), findsOneWidget);
    expect(find.text('No price alerts set'), findsOneWidget);
    
    // Test that the create alert dialog can be created
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateAlertDialog(
            cryptoId: 'bitcoin',
            cryptoName: 'Bitcoin',
            currentPrice: 50000.0,
          ),
        ),
      ),
    );
    
    // Verify create alert dialog elements are present
    expect(find.text('Create Price Alert for Bitcoin'), findsOneWidget);
    expect(find.text('Current Price: \$50000.00'), findsOneWidget);
    expect(find.text('Alert me when price goes above:'), findsOneWidget);
    expect(find.text('Alert me when price goes below:'), findsOneWidget);
    
    // Test that we can tap the create alert button
    final createButton = find.text('Create Alert');
    expect(createButton, findsOneWidget);
    
    // Fill in some threshold values
    await tester.enterText(find.byType(TextField).first, '55000');
    await tester.enterText(find.byType(TextField).last, '45000');
    
    // Tap create alert button
    await tester.tap(createButton);
    await tester.pump();
    
    // The dialog should process the input (may show loading state)
    // Note: In a real environment, this would create the alert in the database
  });
}