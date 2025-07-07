import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cryptotracker/models/price_alert.dart';
import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/settingsDB.dart';

class AlertService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  static Timer? _monitoringTimer;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (kDebugMode) {
          print('notification payload: ${response.payload}');
        }
      },
    );

    _isInitialized = true;
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'price_alerts',
      'Price Alerts',
      channelDescription: 'Notifications for cryptocurrency price alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Price Alert',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> startMonitoring() async {
    if (_monitoringTimer != null) return;

    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkPriceAlerts();
    });
  }

  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  static Future<void> _checkPriceAlerts() async {
    try {
      final alerts = await DatabaseService.getActivePriceAlerts();
      final currencySymbol = SettingsDb.getValue("settings", "currencySymbol");
      
      for (final alert in alerts) {
        final crypto = await getCoinData(alert.cryptoId);
        if (crypto?.price != null) {
          final currentPrice = crypto!.price!;
          
          if (alert.shouldTriggerAbove(currentPrice)) {
            await showNotification(
              title: '${alert.cryptoName} Price Alert',
              body: '${alert.cryptoName} has risen above $currencySymbol${alert.thresholdAbove?.toStringAsFixed(2)} to $currencySymbol${currentPrice.toStringAsFixed(2)}',
              payload: alert.cryptoId,
            );
            await DatabaseService.markAlertTriggered(alert.id!);
          }
          
          if (alert.shouldTriggerBelow(currentPrice)) {
            await showNotification(
              title: '${alert.cryptoName} Price Alert',
              body: '${alert.cryptoName} has dropped below $currencySymbol${alert.thresholdBelow?.toStringAsFixed(2)} to $currencySymbol${currentPrice.toStringAsFixed(2)}',
              payload: alert.cryptoId,
            );
            await DatabaseService.markAlertTriggered(alert.id!);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking price alerts: $e');
      }
    }
  }

  static Future<void> createAlert({
    required String cryptoId,
    required String cryptoName,
    double? thresholdAbove,
    double? thresholdBelow,
  }) async {
    if (thresholdAbove == null && thresholdBelow == null) {
      throw Exception('At least one threshold must be provided');
    }

    final alert = PriceAlert(
      cryptoId: cryptoId,
      cryptoName: cryptoName,
      thresholdAbove: thresholdAbove,
      thresholdBelow: thresholdBelow,
      createdAt: DateTime.now(),
    );

    await DatabaseService.createPriceAlert(alert);
  }
}