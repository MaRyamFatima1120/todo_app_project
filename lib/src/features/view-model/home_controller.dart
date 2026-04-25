import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants/app_color.dart';
import '../../common/utils/supabase_service.dart';

class HomeController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  var showFilter = false.obs;
  var searchQuery = ''.obs;
  var title = ''.obs;
  var description = ''.obs;
  var time = ''.obs;
  var filteredTask = "all".obs;


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
      final newTask = {
        'user_id': user?.id,
        'title': title.value,
        'description': description.value,
        'timeStamp': DateTime.now().toIso8601String(),
        'completed': false
      };

      // Save to Supabase
      final savedTask = await _supabaseService.addTask(newTask);
      
      if (savedTask != null) {
        addData.add(savedTask);
        searchData.value = addData;
        clearFormField();
        await updateSharedPreference(); // Keep local sync for offline
      }
    } else {
      debugPrint("Field is Empty!");
    }
  }

// Clear form fields
  void clearFormField() {
    title.value = '';
    description.value = '';
  }

//Completed Task
  void toggleTaskCompletion(dynamic taskId) async {
    try {
      // Find the task by id
      var taskIndex = addData.indexWhere((task) => task['id'].toString() == taskId.toString());
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
      await _supabaseService.updateTask(taskId.toString(), {'completed': newStatus});
      
      // 3. Update Local Storage
      await updateSharedPreference();
      
      debugPrint("Successfully toggled task: $taskId to $newStatus");
    } catch (e) {
      debugPrint("Error toggling task: $e");
      Get.snackbar(
        "Database Error",
        "Failed to update task. Please check your connection or SQL setup.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  //Retrieve Data
  Future<void> loadData() async {
    // Try to load from Supabase first
    List<Map<String, dynamic>> supabaseTasks = await _supabaseService.getTasks();
    
    if (supabaseTasks.isNotEmpty) {
      addData.value = supabaseTasks;
      searchData.value = addData;
      await updateSharedPreference(); // Sync local storage
    } else {
      // Fallback to local storage if Supabase is empty or offline
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
    
    addData.removeAt(index);
    updateSharedPreference();
    searchData.value = addData;
  }

  @override
  void onInit() {
    super.onInit();
    loadData().then((_) {
      taskSearchData.value = getFilteredTasks(); // Initialize with all tasks
    });
  }

  //editTask
  void editTask(int index, String newTitle, String newDescription) async {
    String taskId = addData[index]['id'].toString();
    String timeStamp = DateTime.now().toIso8601String();
    
    final updates = {
      'title': newTitle,
      'description': newDescription,
      'timeStamp': timeStamp,
    };

    // Update Supabase
    await _supabaseService.updateTask(taskId, updates);

    addData[index]['title'] = newTitle;
    addData[index]['description'] = newDescription;
    addData[index]['timeStamp'] = timeStamp;
    addData.refresh();
    updateSharedPreference();
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
            return taskDate.isAfter(DateTime.now().subtract(const Duration(minutes: 30)));
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
