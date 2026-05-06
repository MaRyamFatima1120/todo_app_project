import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants/app_color.dart';
import '../../common/utils/supabase_service.dart';
import '../../common/utils/notification_service.dart';
import '../../common/utils/snack_bar_custom.dart';

class HomeController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  var showFilter = false.obs;
  var searchQuery = ''.obs;
  var title = ''.obs;
  var description = ''.obs;
  var time = ''.obs;
  var filteredTask = "all".obs;
  var reminderTime = Rxn<DateTime>();
  final NotificationService _notificationService = NotificationService();

  // Stream subscription for clean up
  StreamSubscription<List<Map<String, dynamic>>>? _taskSubscription;

  //Observable List to hold data
  RxList<Map<String, dynamic>> addData = <Map<String, dynamic>>[].obs;

  //Observable List to hold data
  var searchData = <Map<String, dynamic>>[].obs;
  var taskSearchData = <Map<String, dynamic>>[].obs;

//Filter
  void showFilterFunction() {
    showFilter.value = !showFilter.value;
  }

  void onChangedFunction(String query) {
    searchQuery.value = query.toLowerCase();
    searchData.value = addData
        .where((item) =>
            item['title'].toLowerCase().contains(searchQuery.value) ||
            item['description'].toLowerCase().contains(searchQuery.value))
        .toList();
    debugPrint("Search Query:${searchQuery.value}");
  }

  // Search function for task view
  void searchTaskView(String query) {
    searchQuery.value = query.toLowerCase();

    // Apply the search on the filtered tasks, not the whole list
    taskSearchData.value = getFilteredTasks().where((item) {
      return item['title'].toLowerCase().contains(searchQuery.value) ||
          item['description'].toLowerCase().contains(searchQuery.value);
    }).toList();

    debugPrint("Task View Search Query: $query");
  }

  Future<void> saveData() async {
    if (title.value.isNotEmpty && description.value.isNotEmpty) {
      final user = _supabaseService.currentUser;
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final newTask = {
        'id': tempId, // Temporary ID for instant UI update
        'user_id': user?.id,
        'title': title.value,
        'description': description.value,
        'timeStamp': DateTime.now().toIso8601String(),
        'completed': false,
        'reminder_time': reminderTime.value?.toIso8601String(),
      };

      // 1. Instant UI Update (Add to local list immediately)
      addData.insert(0, newTask); // Insert at the top for better visibility
      searchData.value = List.from(addData);
      onChangedFunction(searchQuery.value); // Update search list if active
      clearFormField();

      try {
        // 2. Background Sync to Supabase
        final syncTask = {
          'user_id': newTask['user_id'],
          'title': newTask['title'],
          'description': newTask['description'],
          'timeStamp': newTask['timeStamp'],
          'completed': newTask['completed'],
          'reminder_time': newTask['reminder_time'],
        };

        final savedTask = await _supabaseService.addTask(syncTask);

        if (savedTask != null) {
          // Replace temp task with the real one from database (to get real ID)
          int index = addData.indexWhere((task) => task['id'] == tempId);
          if (index != -1) {
            addData[index] = savedTask;
            addData.refresh();
            searchData.value = List.from(addData);
          }

          // Schedule notification if reminderTime is set
          if (reminderTime.value != null) {
            await _notificationService.scheduleTaskReminder(
              id: savedTask['id'].hashCode,
              title: savedTask['title'],
              body: savedTask['description'],
              scheduledTime: reminderTime.value!,
            );
          }

          await updateSharedPreference();
          _scheduleDailyDigest();
          debugPrint("Task synced successfully with Supabase");
        }
      } catch (e) {
        debugPrint("Error syncing task: $e");
        // Optionally show a "Sync failed" indicator or retry logic
      }
    } else {
      debugPrint("Field is Empty!");
    }
  }

// Clear form fields
  void clearFormField() {
    title.value = '';
    description.value = '';
    reminderTime.value = null;
  }

//Completed Task
  void toggleTaskCompletion(dynamic taskId) async {
    try {
      // Find the task by id
      var taskIndex = addData
          .indexWhere((task) => task['id'].toString() == taskId.toString());
      if (taskIndex == -1) return;

      var task = addData[taskIndex];
      bool newStatus = !(task['completed'] ?? false);

      // 1. Update UI Immediately (Local)
      task['completed'] = newStatus;
      addData.refresh();
      onChangedFunction(searchQuery.value);
      taskSearchData.value = getFilteredTasks();
      update();

      // 2. Update Supabase
      await _supabaseService
          .updateTask(taskId.toString(), {'completed': newStatus});

      // 3. Update Local Storage
      await updateSharedPreference();
      _scheduleSummaryNotifications();

      // Achievement: If all tasks are completed
      if (newStatus && getTasksByFilter('pending').isEmpty) {
        _notificationService.showAchievementNotification(
          "Amazing! You've completed all your tasks for today"
        );
      }

      debugPrint("Successfully toggled task: $taskId to $newStatus");
    } catch (e) {
      debugPrint("Error toggling task: $e");
      CustomSnackBar.error(
        "Failed to update task. Please check your connection or SQL setup",
        title: "Database Error",
      );
    }
  }

  //Retrieve Data
  Future<void> loadData() async {
    // Try to load from Supabase first
    List<Map<String, dynamic>> supabaseTasks =
        await _supabaseService.getTasks();

    final user = _supabaseService.currentUser;

    if (user != null) {
      // If we are online and have a result (even if empty), trust the database
      addData.value = supabaseTasks;
      searchData.value = addData;
      await updateSharedPreference(); // Keep local storage in sync
      _syncReminders();
      _scheduleSummaryNotifications();
      debugPrint("Data loaded from Supabase. Count: ${supabaseTasks.length}");
    } else {
      // Only fallback to SharedPreferences if we are truly offline/logged out
      SharedPreferences prefers = await SharedPreferences.getInstance();
      String? jsonData = prefers.getString('data');

      if (jsonData != null) {
        List<dynamic> decodeData = jsonDecode(jsonData);
        addData.value = List<Map<String, dynamic>>.from(decodeData.map((task) {
          if (!task.containsKey('id')) {
            task['id'] = 'unique_id_${addData.length + 1}';
          }
          return task;
        }));
        searchData.value = addData;
      }
    }
  }

//Delete Data
  void deleteData(int index) async {
    String taskId = addData[index]['id'].toString();

    // Delete from Supabase
    await _supabaseService.deleteTask(taskId);

    // Cancel notification
    _notificationService.cancelNotification(taskId.hashCode);

    // Update local lists
    addData.removeAt(index);
    searchData.value = List.from(addData);
    taskSearchData.value = getFilteredTasks();
    
    // Sync to local storage
    await updateSharedPreference();
    
    _scheduleSummaryNotifications();
    update();
    debugPrint("Deleted task $taskId and synced local storage.");
  }

  @override
  void onInit() {
    super.onInit();
    _startRealtimeListener();
    _scheduleSummaryNotifications();
  }

  @override
  void onClose() {
    _taskSubscription?.cancel();
    super.onClose();
  }

  void _startRealtimeListener() {
    _taskSubscription = _supabaseService.getTasksStream().listen((tasks) {
      addData.value = tasks;
      searchData.value = List.from(tasks);
      onChangedFunction(searchQuery.value); // Keep search in sync
      taskSearchData.value = getFilteredTasks(); // Keep filters in sync
      updateSharedPreference(); // Sync local storage for offline use
      _scheduleSummaryNotifications();
      _syncReminders(); // Sync notifications whenever tasks change
    });
  }

  // Schedule notifications for all upcoming reminders in the task list
  void _syncReminders() {
    for (var task in addData) {
      if (task['reminder_time'] != null && task['completed'] == false) {
        try {
          final reminderTime = DateTime.parse(task['reminder_time']);
          // Call scheduleTaskReminder and let it handle the grace period for past times
          _notificationService.scheduleTaskReminder(
            id: task['id'].toString().hashCode,
            title: task['title'],
            body: task['description'] ?? '',
            scheduledTime: reminderTime,
          );
        } catch (e) {
          debugPrint("Error parsing reminder time for task ${task['id']}: $e");
        }
      }
    }
  }

  void _scheduleSummaryNotifications() {
    int pendingCount = getTasksByFilter('pending').length;
    int completedCount = getTasksByFilter('completed').length;
    
    _notificationService.scheduleDailyDigest(pendingCount);
    _notificationService.scheduleEveningWrapUp(completedCount, pendingCount);
    _notificationService.scheduleInactivityNudge();
  }

  // Deprecated - replaced by _scheduleSummaryNotifications
  void _scheduleDailyDigest() {
    _scheduleSummaryNotifications();
  }

  //editTask
  void editTask(int index, String newTitle, String newDescription) async {
    String taskId = addData[index]['id'].toString();
    String timeStamp = DateTime.now().toIso8601String();

    final updates = {
      'title': newTitle,
      'description': newDescription,
      'timeStamp': timeStamp,
      'reminder_time': reminderTime.value?.toIso8601String(),
    };

    // Update Supabase
    await _supabaseService.updateTask(taskId, updates);

    // Reschedule notification if needed
    if (reminderTime.value != null) {
      await _notificationService.cancelNotification(taskId.hashCode);
      await _notificationService.scheduleTaskReminder(
        id: taskId.hashCode,
        title: newTitle,
        body: newDescription,
        scheduledTime: reminderTime.value!,
      );
    }

    addData[index]['title'] = newTitle;
    addData[index]['description'] = newDescription;
    addData[index]['timeStamp'] = timeStamp;
    addData[index]['reminder_time'] = reminderTime.value?.toIso8601String();
    addData.refresh();
    updateSharedPreference();
    clearFormField();
    update();
  }

  //updateTask
  Future<void> updateSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert addData list to JSON format for SharedPreferences
    String jsonData = jsonEncode(addData);

    // Save the JSON string to SharedPreferences
    await prefs.setString('data', jsonData);
  }

  // Get filtered tasks based on a specific filter type
  List<Map<String, dynamic>> getTasksByFilter(String type) {
    switch (type) {
      case 'recent':
        return addData.where((task) {
          try {
            final taskDate = DateTime.parse(task['timeStamp']);
            return taskDate
                .isAfter(DateTime.now().subtract(const Duration(minutes: 30)));
          } catch (e) {
            return false;
          }
        }).toList();
      case 'completed':
        return addData.where((task) => task['completed'] == true).toList();
      case 'pending':
        return addData.where((task) => task['completed'] == false).toList();
      default:
        return addData.toList();
    }
  }

  // Get filtered tasks based on the current selected filter
  List<Map<String, dynamic>> getFilteredTasks() {
    return getTasksByFilter(filteredTask.value);
  }

  // FilterTask (Update global state)
  List<Map<String, dynamic>> applyFilterType(String type) {
    filteredTask.value = type;
    taskSearchData.value = getFilteredTasks();
    return taskSearchData;
  }

  LinearGradient getGradient(int index) {
    if (index % 2 == 0) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColor.orangeColor, AppColor.yellowColor],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColor.blueColor, AppColor.purpleColor],
      );
    }
  }

  Color getIconColor(int index) {
    return index % 2 == 0 ? AppColor.redOrangeColor : AppColor.blueColor;
  }

  String formatDate(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();

      // Check if the date is today
      if (isSameDay(now, dateTime)) {
        return "Today, ${DateFormat('HH:mm a').format(dateTime)}"; // Time only for today
      }
      // Check if the date is yesterday
      else if (isSameDay(now.subtract(const Duration(days: 1)), dateTime)) {
        return "Yesterday, ${DateFormat('HH:mm a').format(dateTime)}";
      } else {
        return DateFormat('d MMMM, yyyy HH:mm a').format(dateTime);
      }
    } catch (e) {
      debugPrint("Date format error: $e");
      return "Invalid date";
    }
  }

// Helper function to check if two dates are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
