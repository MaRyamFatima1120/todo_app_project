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
        AndroidInitializationSettings('@drawable/launch_background'); // Using a more standard drawable
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [],
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

    // Set foreground notification presentation options for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    // This allows notifications to be shown even when the app is in the foreground on iOS
    // We can also set this in the initialize call for newer versions if needed

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
      final dynamic timeZone = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = "";
      
      if (timeZone is String) {
        timeZoneName = timeZone;
      } else {
        // If it's a TimezoneInfo object, it usually has a 'name' property
        try {
          timeZoneName = (timeZone as dynamic).name;
        } catch (e) {
          timeZoneName = timeZone.toString();
        }
      }

      // Handle cases like "TimezoneInfo(Asia/Karachi, ...)" or "locale: en-US, name: Asia/Karachi"
      if (timeZoneName.contains('name:')) {
        timeZoneName = timeZoneName.split('name:').last.split(',').first.split(')').first.trim();
      } else if (timeZoneName.contains('(')) {
        timeZoneName = timeZoneName.split('(').last.split(',').first.split(')').first.trim();
      }
      
      // If we still get something like "locale: en-US", fallback to a guess or UTC
      if (timeZoneName.contains('locale:')) {
        debugPrint("Warning: Timezone detection returned locale instead of name. Defaulting to Asia/Karachi for testing or UTC.");
        timeZoneName = "Asia/Karachi";
      }

      // Handle common human-readable names to IANA names mapping
      if (timeZoneName == "Pakistan Standard Time") {
        timeZoneName = "Asia/Karachi";
      }
      
      debugPrint("Detected Timezone Name: $timeZoneName");
      tz.setLocalLocation(tz.getLocation(timeZoneName));
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

    // Track notified task IDs to avoid duplicates
    final Set<String> notifiedTaskIds = {};

    // Listen to tasks added to the database
    Supabase.instance.client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        // Sort by created_at or timestamp if available, otherwise assume latest is first
        // Check for new tasks that haven't been notified yet
        for (var task in data) {
          final String taskId = task['id'].toString();
          final String taskTitle = task['title'] ?? 'New Task';
          
          // Check if task was created in the last 10 seconds to avoid notifying old tasks
          final DateTime createdAt = DateTime.tryParse(task['timeStamp'] ?? '') ?? DateTime.now();
          final bool isRecent = DateTime.now().difference(createdAt).inSeconds < 10;

          if (!notifiedTaskIds.contains(taskId) && isRecent) {
            notifiedTaskIds.add(taskId);
            
            showInstantNotification(
              id: taskId.hashCode, // Unique ID based on Task ID
              title: "Taskify Sync: $taskTitle",
              body: "Your task has been synced successfully.",
            );
          }
        }
      }
    });
  }

  // Show an instant notification (Useful for Real-time triggers)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Ensure ID is a positive 32-bit integer
    final int safeId = id.abs() % 2147483647;

    const  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_notifications_v3',
      'Instant Updates',
      channelDescription: 'Real-time updates from Taskify',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/launch_background',
    );

    const  NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS:  DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
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
    debugPrint("Scheduling reminder: $title at $scheduledTime (Local Now: ${DateTime.now()})");
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // Ensure ID is a positive 32-bit integer
    final int safeId = id.abs() % 2147483647;

    debugPrint("Scheduling: $title | SafeID: $safeId | Time: $tzScheduledTime");

    // Prevent scheduling in the past (with a 10-minute grace period for missed reminders)
    if (tzScheduledTime.isBefore(now)) {
      if (now.difference(tzScheduledTime).inMinutes < 10) {
        await showInstantNotification(
          id: safeId,
          title: title,
          body: body,
        );
      }
      return;
    }
    debugPrint("TZ Scheduled Time: $tzScheduledTime (TZ Local Now: ${tz.TZDateTime.now(tz.local)})");

    await _notificationsPlugin.zonedSchedule(
      id: safeId,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders_v3',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/launch_background',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
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
      title: 'Morning Briefing ☀️',
      body: 'Good morning! You have $pendingTasksCount pending tasks today. Let\'s get productive!',
      scheduledDate: _nextInstanceOfTime(9, 0),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summaries',
          channelDescription: 'Morning and evening task summaries',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule Evening Wrap-up at 8:00 PM
  Future<void> scheduleEveningWrapUp(int completedCount, int remainingCount) async {
    String body = completedCount > 0 
        ? 'Great job! You completed $completedCount tasks today. $remainingCount remaining for tomorrow.'
        : 'The day is almost over! You have $remainingCount tasks to look at for tomorrow.';

    await _notificationsPlugin.zonedSchedule(
      id: 998, // Unique ID for evening wrap-up
      title: 'Evening Wrap-up 🌙',
      body: body,
      scheduledDate: _nextInstanceOfTime(20, 0),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summaries',
          channelDescription: 'Morning and evening task summaries',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule Inactivity Nudge (48 hours from now)
  Future<void> scheduleInactivityNudge() async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(hours: 48));

    await _notificationsPlugin.zonedSchedule(
      id: 997,
      title: 'We Miss You! 👋',
      body: 'You haven\'t checked your tasks in a while. Let\'s get back on track!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'General Reminders',
          channelDescription: 'Nudges and achievement notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Show Achievement Notification
  Future<void> showAchievementNotification(String message) async {
    await showInstantNotification(
      id: 888,
      title: 'Goal Achieved! 🏆',
      body: message,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Deprecated - replaced by _nextInstanceOfTime
  tz.TZDateTime _nextInstanceOfNineAM() {
    return _nextInstanceOfTime(9, 0);
  }
}
