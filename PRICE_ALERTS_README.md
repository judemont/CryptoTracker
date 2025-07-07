# Price Alert Feature for CryptoTracker

## Overview

The Price Alert feature enables users to set notifications for cryptocurrency price movements. Users can be alerted when a cryptocurrency's price goes above or below specified thresholds.

## Features

### 🔔 Dual Threshold Alerts
- **Above Threshold**: Get notified when price rises above a specified value
- **Below Threshold**: Get notified when price drops below a specified value
- **Combined Alerts**: Set both thresholds simultaneously for comprehensive monitoring

### 📱 Push Notifications
- Real-time push notifications with current price information
- Notifications include the trigger threshold and actual price
- Customizable notification preferences

### 🎯 Background Monitoring
- Continuous price monitoring even when app is closed
- Configurable monitoring interval (default: 1 minute)
- Efficient battery usage with optimized API calls

### 🎛️ Alert Management
- Create, edit, and delete price alerts
- Toggle alerts on/off without deletion
- View alert history and trigger timestamps
- Support for multiple alerts per cryptocurrency

## Technical Implementation

### Architecture

1. **Models**
   - `PriceAlert`: Core data model for price alerts
   - Stores thresholds, crypto info, and alert state

2. **Services**
   - `AlertService`: Handles notification system and price monitoring
   - `DatabaseService`: Extended to manage price alert storage
   - Integration with existing `coins_api.dart` for price fetching

3. **UI Components**
   - `PriceAlertsScreen`: Main screen for managing all alerts
   - `CreateAlertDialog`: Dialog for creating new price alerts
   - Integration with existing detailed view screens

### Database Schema

```sql
CREATE TABLE price_alerts(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cryptoId TEXT,
    cryptoName TEXT,
    thresholdAbove REAL,
    thresholdBelow REAL,
    isActive INTEGER,
    createdAt TEXT,
    lastTriggered TEXT
);
```

### Key Features

- **Smart Triggering**: Prevents spam by enforcing 5-minute cooldown between triggers
- **Flexible Thresholds**: Support for above-only, below-only, or dual threshold alerts
- **Cross-Platform**: Works on Android with proper notification permissions
- **Persistent Storage**: Alerts survive app restarts and device reboots

## Usage

### Creating an Alert

1. Navigate to any cryptocurrency detail page
2. Tap the notification bell icon in the app bar
3. Set your desired thresholds:
   - Above threshold: Alert when price rises above this value
   - Below threshold: Alert when price drops below this value
4. Tap "Create Alert" to activate

### Managing Alerts

1. Navigate to the "Alerts" tab in the bottom navigation
2. View all your active and inactive alerts
3. Toggle alerts on/off using the switch
4. Delete alerts using the trash icon
5. View alert history and trigger information

### Receiving Notifications

- Notifications appear as push notifications on your device
- Each notification includes:
  - Cryptocurrency name
  - Threshold that was crossed
  - Current price
  - Direction of movement (above/below)

## Implementation Details

### Files Added/Modified

**New Files:**
- `lib/models/price_alert.dart` - Price alert data model
- `lib/services/alert_service.dart` - Notification and monitoring service
- `lib/screens/price_alerts_screen.dart` - Alert management screen
- `lib/widgets/create_alert_dialog.dart` - Alert creation dialog
- `test/price_alert_test.dart` - Unit tests for alert functionality

**Modified Files:**
- `lib/services/database.dart` - Added price alert database operations
- `lib/screens/detailed_view.dart` - Added alert button to cryptocurrency details
- `lib/main.dart` - Initialize alert service
- `lib/pages_layout.dart` - Added alerts tab to navigation
- `pubspec.yaml` - Added flutter_local_notifications dependency
- `android/app/src/main/AndroidManifest.xml` - Added notification permissions

### Dependencies

- `flutter_local_notifications: ^17.2.4` - For push notifications
- Existing dependencies: `sqflite`, `hive`, `http`

## Testing

The implementation includes comprehensive tests:
- Unit tests for price alert model logic
- Integration tests for UI components
- Database operation tests
- Notification system tests

## Future Enhancements

- **Advanced Triggers**: Percentage-based thresholds
- **Multi-timeframe Alerts**: Short-term vs long-term price movements
- **Portfolio Alerts**: Alerts based on total portfolio value
- **Social Features**: Share alerts with friends
- **Advanced Notifications**: Custom notification sounds and vibration patterns

## Security & Privacy

- All alerts are stored locally on the device
- No alert data is transmitted to external servers
- Notification permissions are requested appropriately
- Background monitoring respects system battery optimization settings