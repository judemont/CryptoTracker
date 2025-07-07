import 'package:flutter_test/flutter_test.dart';
import 'package:cryptotracker/models/price_alert.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/services/alert_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('Price Alert Tests', () {
    setUpAll(() async {
      // Initialize SQLite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('PriceAlert model should trigger above threshold', () {
      final alert = PriceAlert(
        cryptoId: 'bitcoin',
        cryptoName: 'Bitcoin',
        thresholdAbove: 50000.0,
        createdAt: DateTime.now(),
      );

      // Price above threshold should trigger
      expect(alert.shouldTriggerAbove(55000.0), true);
      
      // Price below threshold should not trigger
      expect(alert.shouldTriggerAbove(45000.0), false);
    });

    test('PriceAlert model should trigger below threshold', () {
      final alert = PriceAlert(
        cryptoId: 'bitcoin',
        cryptoName: 'Bitcoin',
        thresholdBelow: 50000.0,
        createdAt: DateTime.now(),
      );

      // Price below threshold should trigger
      expect(alert.shouldTriggerBelow(45000.0), true);
      
      // Price above threshold should not trigger
      expect(alert.shouldTriggerBelow(55000.0), false);
    });

    test('PriceAlert model should convert to/from map', () {
      final alert = PriceAlert(
        cryptoId: 'bitcoin',
        cryptoName: 'Bitcoin',
        thresholdAbove: 50000.0,
        thresholdBelow: 40000.0,
        createdAt: DateTime.now(),
      );

      final map = alert.toMap();
      final restoredAlert = PriceAlert.fromMap(map);

      expect(restoredAlert.cryptoId, alert.cryptoId);
      expect(restoredAlert.cryptoName, alert.cryptoName);
      expect(restoredAlert.thresholdAbove, alert.thresholdAbove);
      expect(restoredAlert.thresholdBelow, alert.thresholdBelow);
      expect(restoredAlert.isActive, alert.isActive);
    });

    test('AlertService should create alert with valid parameters', () async {
      // Test that creating an alert with valid parameters doesn't throw
      try {
        await AlertService.createAlert(
          cryptoId: 'bitcoin',
          cryptoName: 'Bitcoin',
          thresholdAbove: 50000.0,
        );
        // If we get here, the test passed
        expect(true, true);
      } catch (e) {
        // If we get here, the test failed
        fail('AlertService.createAlert should not throw with valid parameters');
      }
    });

    test('AlertService should throw error with no thresholds', () async {
      // Test that creating an alert with no thresholds throws an error
      try {
        await AlertService.createAlert(
          cryptoId: 'bitcoin',
          cryptoName: 'Bitcoin',
        );
        fail('AlertService.createAlert should throw error with no thresholds');
      } catch (e) {
        expect(e.toString(), contains('At least one threshold must be provided'));
      }
    });
  });
}