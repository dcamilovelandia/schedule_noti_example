
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {


  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification
  initializeNotification() async {

    /// notifications
    _configureLocalTimeZone();
    const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("ic_stat_android");

    const InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  /// Scheduled Notification
  scheduledNotification({
    required int hour,
    required int minutes,
    required int id,
    required String sound,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'It\'s time to drink water!',
      'After drinking, touch the cup to confirm',
      _convertTime(hour, minutes),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id $sound',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.max,

          sound: RawResourceAndroidNotificationSound(sound),
        ),
        iOS: IOSNotificationDetails(sound: '$sound.mp3'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'It could be anything you pass',
    ).whenComplete(() {print('completed');});
  }

  /// Request IOS permissions
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}