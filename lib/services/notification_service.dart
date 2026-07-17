import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Required for scheduling future alarms

    // Uses the default Android app icon for the notification
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
  }

  static Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // Starts the daily 5x nagging cycle
  static Future<void> scheduleDailyReminders() async {
    await _notificationsPlugin.cancelAll(); // Clear old ones first

    // Your requested schedule: 8am, 11am, 2pm, 5pm, 8pm
    final scheduleHours = [8, 11, 14, 17, 20];
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < scheduleHours.length; i++) {
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduleHours[i],
        0,
      );

      // If the time has already passed today, schedule it for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _schedule(id: i, scheduledDate: scheduledDate);
    }
  }

  // When the user checks the alert in the app, cancel today's nagging and restart tomorrow!
  static Future<void> cancelAndRescheduleForTomorrow() async {
    await _notificationsPlugin.cancelAll();

    final scheduleHours = [8, 11, 14, 17, 20];
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < scheduleHours.length; i++) {
      // Force scheduling starting tomorrow by adding 1 day
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        scheduleHours[i],
        0,
      );
      await _schedule(id: i, scheduledDate: scheduledDate);
    }
  }

  static Future<void> _schedule({
    required int id,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'farm_reminders',
          'Farm Reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'Farm Records Reminder 🐓',
      body: 'Don\'t forget to log your feed, eggs, and check for mortalities!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // DELETED: uiLocalNotificationDateInterpretation (No longer needed in v17!)
      matchDateTimeComponents:
          DateTimeComponents.time, // Makes it repeat every day at this time
    );
  }
}
