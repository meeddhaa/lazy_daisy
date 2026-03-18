import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationHelper() {
    _init();
  }

  void _init() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  // ─────────────────────────────────────────────
  // EXISTING: Global daily reminder (kept intact)
  // ─────────────────────────────────────────────
  Future<void> showDailyReminder(
    int hour,
    int minute,
    BuildContext context,
  ) async {
    await flutterLocalNotificationsPlugin.cancel(0);

    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission is required for reminders'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (await _isAndroid12OrHigher()) {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
        if (!exactAlarmStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please enable exact alarm permission in settings',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    bool exactScheduled = false;

    if (Platform.isAndroid) {
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Habit Reminder',
          'Time to check your habits!',
          _nextInstanceOfTime(hour: hour, minute: minute),
          platformDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        exactScheduled = true;
      } catch (e) {
        debugPrint('Exact alarm failed, falling back: $e');
        try {
          await flutterLocalNotificationsPlugin.periodicallyShow(
            0,
            'Habit Reminder',
            'Time to check your habits!',
            RepeatInterval.daily,
            platformDetails,
            androidAllowWhileIdle: true,
          );
        } catch (e) {
          debugPrint('Approximate alarm also failed: $e');
        }
      }
    } else {
      try {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          0,
          'Habit Reminder',
          'Time to check your habits!',
          RepeatInterval.daily,
          platformDetails,
          androidAllowWhileIdle: true,
        );
      } catch (e) {
        debugPrint('iOS notification scheduling failed: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exactScheduled
              ? 'Exact daily reminder scheduled!'
              : 'Approximate daily reminder scheduled!',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ✅ NEW: Schedule reminder for a specific habit
  // Uses habit.id as the notification ID so each
  // habit gets its own unique notification slot.
  // ─────────────────────────────────────────────
  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    // Use habitId + 100 as notification ID to avoid clash with global reminder (id=0)
    final notificationId = habitId + 100;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'habit_reminder_channel',
      'Habit Reminders',
      channelDescription: 'Reminders for individual habits',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Time for: $habitName',
        'Don\'t break your streak! Complete your habit now.',
        _nextInstanceOfTime(hour: hour, minute: minute),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled reminder for "$habitName" at $hour:$minute');
    } catch (e) {
      debugPrint('Failed to schedule habit reminder: $e');
    }
  }

  // ✅ NEW: Cancel reminder for a specific habit
  Future<void> cancelHabitReminder(int habitId) async {
    final notificationId = habitId + 100;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    debugPrint('Cancelled reminder for habit id: $habitId');
  }

  // ✅ NEW: Cancel all habit reminders
  Future<void> cancelAllHabitReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All reminders cancelled');
  }

  Future<bool> _isAndroid12OrHigher() async {
    if (!Platform.isAndroid) return false;
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        true;
  }

  tz.TZDateTime _nextInstanceOfTime({required int hour, required int minute}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
