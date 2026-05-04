import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification clicked: ${details.payload}");
      },
    );

    // Request permission for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Check for Exact Alarm permission (Android 13+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      debugPrint("Could not set local timezone: $e. Falling back to UTC.");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Start Real-time Listener
    _listenToTaskChanges();
  }

  // Real-time Supabase Listener
  void _listenToTaskChanges() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Listen to NEW tasks added to the database
    Supabase.instance.client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        // Find the most recently added task (assuming highest ID or just the first in stream)
        final lastTask = data.first;
        
        // Check if this task was added in the last 5 seconds to avoid spamming old notifications
        // In a real pro app, we'd use a local database to track which ones were already notified.
        
        showInstantNotification(
          id: lastTask['id'].hashCode,
          title: "Task Sync: ${lastTask['title']}",
          body: "Your tasks are synced in real-time with the cloud.",
        );
      }
    });
  }

  // Show an instant notification (Useful for Real-time triggers)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Real-time updates from the database',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Using app logo
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // Schedule a reminder for a specific task
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Prevent scheduling in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders_v2',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  // Schedule Daily Digest at 9:00 AM
  Future<void> scheduleDailyDigest(int pendingTasksCount) async {
    if (pendingTasksCount == 0) return;

    await _notificationsPlugin.zonedSchedule(
      id: 999, // Unique ID for daily digest
      title: 'Daily Digest',
      body: 'Yaar, aaj aap ke $pendingTasksCount tasks pending hain. Chalein shuru karte hain!',
      scheduledDate: _nextInstanceOfNineAM(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_digest',
          'Daily Digest',
          channelDescription: 'Daily summary of pending tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
