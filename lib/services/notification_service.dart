import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/warranty_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to warranty detail
  }

  // Check warranties and schedule notifications for expiring ones
  Future<void> checkAndScheduleNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await ApiService.get(ApiConfig.warranties);
      if (response['success'] != true) return;

      final warranties = (response['data'] as List)
          .map((e) => WarrantyRegistration.fromJson(e))
          .toList();

      // Cancel all existing notifications
      await _notifications.cancelAll();

      int notificationId = 0;

      for (final warranty in warranties) {
        if (warranty.status.toLowerCase() == 'expired') continue;

        final daysUntilExpiry = warranty.warrantyEndDate.difference(DateTime.now()).inDays;

        // Schedule notifications at different intervals before expiry
        if (daysUntilExpiry <= 30 && daysUntilExpiry > 0) {
          // Expiring within 30 days - notify immediately
          await _showNotification(
            id: notificationId++,
            title: '⚠️ Warranty Expiring Soon!',
            body: '${warranty.productName} (SN: ${warranty.serialNumber}) expires in $daysUntilExpiry days',
            payload: warranty.id.toString(),
          );
        }

        if (daysUntilExpiry == 7 || daysUntilExpiry == 15 || daysUntilExpiry == 30) {
          // Schedule reminder
          await _scheduleNotification(
            id: notificationId++,
            title: '🔔 Warranty Reminder',
            body: '${warranty.productName} warranty expires in $daysUntilExpiry days. SN: ${warranty.serialNumber}',
            scheduledDate: DateTime.now().add(const Duration(hours: 9)), // Next morning 9 AM
            payload: warranty.id.toString(),
          );
        }

        // Schedule notification for 7 days before expiry
        if (daysUntilExpiry > 7) {
          final sevenDaysBefore = warranty.warrantyEndDate.subtract(const Duration(days: 7));
          if (sevenDaysBefore.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id: notificationId++,
              title: '⏰ Warranty Expiring in 7 Days',
              body: '${warranty.productName} (SN: ${warranty.serialNumber}) - Contact dealer for renewal',
              scheduledDate: sevenDaysBefore,
              payload: warranty.id.toString(),
            );
          }
        }

        // Schedule notification for 1 day before expiry
        if (daysUntilExpiry > 1) {
          final oneDayBefore = warranty.warrantyEndDate.subtract(const Duration(days: 1));
          if (oneDayBefore.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id: notificationId++,
              title: '🚨 Warranty Expires Tomorrow!',
              body: '${warranty.productName} (SN: ${warranty.serialNumber}) expires TOMORROW!',
              scheduledDate: oneDayBefore,
              payload: warranty.id.toString(),
            );
          }
        }

        // Schedule notification on expiry day
        if (daysUntilExpiry > 0) {
          await _scheduleNotification(
            id: notificationId++,
            title: '❌ Warranty Expired Today',
            body: '${warranty.productName} (SN: ${warranty.serialNumber}) warranty has expired',
            scheduledDate: warranty.warrantyEndDate,
            payload: warranty.id.toString(),
          );
        }
      }

      // Save last check time
      await prefs.setString('lastNotificationCheck', DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail - notifications are non-critical
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'warranty_expiry',
      'Warranty Expiry Alerts',
      channelDescription: 'Notifications for warranty expiry reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3F51B5),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'warranty_expiry_scheduled',
      'Warranty Expiry Reminders',
      channelDescription: 'Scheduled reminders for warranty expiry',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3F51B5),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Get count of expiring warranties for badge
  Future<int> getExpiringSoonCount() async {
    try {
      final response = await ApiService.get(ApiConfig.warrantyByStatus('ExpireSoon'));
      if (response['success'] == true) {
        return (response['data'] as List).length;
      }
    } catch (_) {}
    return 0;
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
