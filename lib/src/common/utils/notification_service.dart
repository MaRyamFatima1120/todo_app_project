import 'dart:async';
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
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Fixed: Using launcher icon for consistency
    
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
      // Handle common human-readable names to IANA names mapping
      if (timeZoneName == "Pakistan Standard Time" || timeZoneName.contains("Karachi") || timeZoneName.contains("PKT")) {
        timeZoneName = "Asia/Karachi";
      } else if (timeZoneName == "India Standard Time" || timeZoneName.contains("Calcutta") || timeZoneName.contains("Kolkata") || timeZoneName.contains("IST")) {
        timeZoneName = "Asia/Kolkata";
      } else if (timeZoneName.contains("GMT+05") || timeZoneName.contains("UTC+05")) {
        timeZoneName = "Asia/Karachi";
      } else if (timeZoneName.contains("GMT+05:30") || timeZoneName.contains("UTC+05:30")) {
        timeZoneName = "Asia/Kolkata";
      } else if (timeZoneName == "China Standard Time" || timeZoneName.contains("Shanghai") || timeZoneName.contains("Beijing") || timeZoneName.contains("CST")) {
        timeZoneName = "Asia/Shanghai";
      }
      
      // Attempt to set local location. If it fails, try to find by offset.
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint("Could not find timezone by name, trying offset fallback...");
        final int offsetInMinutes = DateTime.now().timeZoneOffset.inMinutes;
        if (offsetInMinutes == 300) {
          tz.setLocalLocation(tz.getLocation("Asia/Karachi"));
        } else if (offsetInMinutes == 330) {
          tz.setLocalLocation(tz.getLocation("Asia/Kolkata"));
        } else {
          // Fallback to UTC if all else fails, but this is rare
          tz.setLocalLocation(tz.UTC);
        }
      }
      
      debugPrint("Confirmed System Timezone: ${tz.local.name}");
    } catch (e) {
      debugPrint("Could not set local timezone: $e. Falling back to Asia/Karachi (Default) or UTC.");
      try {
         // Default to Asia/Karachi as a sensible default for the user's region if detection fails
         tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
      } catch (_) {
         tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    // Start Real-time Listener
    _listenToTaskChanges();
  }

  // Real-time Supabase Listener
  StreamSubscription<List<Map<String, dynamic>>>? _taskSubscription;
  final Set<String> _notifiedTaskIds = {}; // Fixed: Moved to class level

  void _listenToTaskChanges() {
    debugPrint("Setting up Auth state listener for notifications...");
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;
      if (user != null) {
        debugPrint("User logged in: ${user.id}. Starting task stream for notifications...");
        _startTaskStream(user.id);
      } else {
        debugPrint("User logged out. Stopping notification task stream and clearing all...");
        _stopTaskStream();
        await cancelAllNotifications(); // Fixed: Cleanup on logout
      }
    });

    // Also check current session immediately in case user is already logged in
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      debugPrint("Current user found: ${currentUser.id}. Starting task stream...");
      _startTaskStream(currentUser.id);
    }
  }

  void _startTaskStream(String userId) {
    _stopTaskStream(); // Avoid duplicate streams

    // Listen to tasks added to the database
    _taskSubscription = Supabase.instance.client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
      debugPrint("Real-time Update (NotificationService): Received ${data.length} tasks");
      if (data.isNotEmpty) {
        for (var task in data) {
          final String taskId = task['id'].toString();
          final String taskTitle = task['title'] ?? 'New Task';
          
          // Check if task was created recently to avoid notifying old tasks
          // Using 60 seconds to be resilient to network delays
          final DateTime createdAt = DateTime.tryParse(task['timeStamp'] ?? '') ?? DateTime.now();
          final int secondsAgo = DateTime.now().difference(createdAt).inSeconds;
          final bool isRecent = secondsAgo < 60;

          if (!_notifiedTaskIds.contains(taskId) && isRecent) {
            _notifiedTaskIds.add(taskId);
            debugPrint("Triggering Sync Notification for: $taskTitle (Created $secondsAgo seconds ago)");
            
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

  void _stopTaskStream() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
    _notifiedTaskIds.clear(); // Fixed: Clear only on explicit stop/logout
  }

  // Show an instant notification (Useful for Real-time triggers)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Ensure ID is a positive 32-bit integer
    final int safeId = id.abs() % 2147483647;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taskify_reminders_v5',
      'Taskify Final Reminders',
      channelDescription: 'High priority alerts for your tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
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
      id: safeId,
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
    final String formattedTitle = 'Reminder: $title';
    const String formattedBody = 'This task is due soon. Tap to review it!';
    
    debugPrint("Scheduling reminder: $formattedTitle at $scheduledTime (Local Now: ${DateTime.now()})");
    
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Convert input DateTime to TZDateTime correctly
    tz.TZDateTime tzScheduledTime;
    if (scheduledTime.isUtc) {
      tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    } else {
      tzScheduledTime = tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
        scheduledTime.second,
      );
    }

    // SMART LOGIC: If the time has already passed for today, move it to tomorrow
    if (tzScheduledTime.isBefore(now) && now.difference(tzScheduledTime).inMinutes > 10) {
       debugPrint("Scheduled time $tzScheduledTime has already passed. Moving to tomorrow.");
       tzScheduledTime = tzScheduledTime.add(const Duration(days: 1));
    }
    
    // Ensure ID is a positive 32-bit integer
    final int safeId = id.abs() % 2147483647;

    debugPrint("SafeID: $safeId | Final Target: $tzScheduledTime (Now: $now)");

    // Final check: if it's still in the past (should only happen if < 10 mins ago)
    if (tzScheduledTime.isBefore(now)) {
      if (now.difference(tzScheduledTime).inMinutes < 10) {
        await showInstantNotification(
          id: safeId,
          title: formattedTitle,
          body: formattedBody,
        );
      }
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id: safeId,
      title: formattedTitle,
      body: formattedBody,
      scheduledDate: tzScheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskify_reminders_v5',
          'Taskify Final Reminders',
          channelDescription: 'High priority alerts for your tasks',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.reminder,
          icon: '@mipmap/ic_launcher',
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

  // Cancel all notifications (e.g., on logout)
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("All notifications cancelled (logout/cleanup).");
  }

  // Schedule Daily Digest at 9:00 AM
  Future<void> scheduleDailyDigest(int pendingTasksCount) async {
    final String body = pendingTasksCount > 0
        ? 'You have $pendingTasksCount task(s) waiting for you today. Let\'s crush it!'
        : 'Your task list is clear today! A perfect time to plan ahead.';

    final scheduledTime = _nextInstanceOfTime(9, 0);
    debugPrint("Scheduling Daily Digest for $scheduledTime with $pendingTasksCount tasks.");

    await _notificationsPlugin.zonedSchedule(
      id: 999, // Unique ID for daily digest
      title: 'Good Morning! ',
      body: body,
      scheduledDate: scheduledTime,
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
    final String body = completedCount > 0 && remainingCount == 0
        ? 'Amazing! You completed all $completedCount tasks today! '
        : completedCount > 0
            ? 'Nice work! $completedCount done, $remainingCount still to go. Tomorrow is a new chance! '
            : 'No tasks done today — that\'s okay! $remainingCount tasks are waiting for you tomorrow. ';

    final scheduledTime = _nextInstanceOfTime(20, 0);
    debugPrint("Scheduling Evening Wrap-up for $scheduledTime. Completed: $completedCount, Remaining: $remainingCount");

    await _notificationsPlugin.zonedSchedule(
      id: 998, // Unique ID for evening wrap-up
      title: 'Day Check-in ',
      body: body,
      scheduledDate: scheduledTime,
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
    await _notificationsPlugin.cancel(id: 997); // Fixed: Prevent stacking by cancelling existing
    
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(hours: 48));
    debugPrint("Scheduling Inactivity Nudge for $scheduledDate (48 hours from now)");

    await _notificationsPlugin.zonedSchedule(
      id: 997,
      title: 'Hey, everything okay? ',
      body: 'You haven\'t visited in a while. Your tasks are patiently waiting for you!',
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
      title: 'Goal Achieved!',
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
}
