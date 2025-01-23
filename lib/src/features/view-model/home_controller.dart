import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants/app_color.dart';

class HomeController extends GetxController {
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
    print("Search Query:${searchQuery.value}");
  }

  // Search function for task view
  void searchTaskView(String query) {
    searchQuery.value = query.toLowerCase();

    // Apply the search on the filtered tasks, not the whole list
    taskSearchData.value = getFilteredTasks().where((item) {
      return item['title'].toLowerCase().contains(searchQuery.value) ||
          item['description'].toLowerCase().contains(searchQuery.value);
    }).toList();

    print("Task View Search Query: $query");
  }

  Future<void> saveData() async {
    if (title.value.isNotEmpty && description.value.isNotEmpty) {
      SharedPreferences prefers = await SharedPreferences.getInstance();

      //// Add new data to addData list
      addData.add({
        'id': 'Unique_id${addData.length + 1}',
        'title': title.value,
        'description': description.value,
        'timeStamp':  DateTime.now().toIso8601String(),
        'completed': false
      });

      // Convert addData list to JSON format for SharedPreferences
      String jsonData = jsonEncode(addData);

      // Save the JSON string to SharedPreferences
      await prefers.setString('data', jsonData);
      searchData.value = addData;
      clearFormField();
    } else {
      print("Field is Empty!");
    }
  }

// Clear form fields
  void clearFormField() {
    title.value = '';
    description.value = '';
  }

//Completed Task
  void toggleTaskCompletion(String taskId) async {
    //Find the task by id
    var task = addData.firstWhere((task) => task['id'] == taskId);
    task['completed'] = !(task['completed'] ?? false);
    update();
    print("Updated Task Status: ${task['completed']}");
    addData.refresh(); // Refresh UI after status change
    // Reapply filters to reflect the updated task status in taskSearchData
    taskSearchData.value = getFilteredTasks();
    await updateSharedPreference();
  }

  //Retrieve Data
  Future<void> loadData() async {
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

//Delete Data
  void deleteData(int index) {
    addData.removeAt(index);
    updateSharedPreference();
    searchData.value = addData;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadData().then((_) {
      taskSearchData.value = getFilteredTasks(); // Initialize with all tasks
    });
  }

  //editTask
  void editTask(int index, String newTitle, String newDescription) {
    addData[index]['title'] = newTitle;
    addData[index]['description'] = newDescription;
    addData[index]['timeStamp'] = DateTime.now().toString();
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

//FilterTask
  List<Map<String, dynamic>> applyFilterType(String type) {
    // Update the filter type
    filteredTask.value = type;
    taskSearchData.value = getFilteredTasks();
    // Return the filtered list based on the filter type
    return taskSearchData;
  }

  // Get filtered tasks based on the selected filter
  List<Map<String, dynamic>> getFilteredTasks() {
    switch (filteredTask.value) {
      case 'recent':
        return addData.where((task) {
          try {
            final taskDate = DateTime.parse(task['timeStamp']);
            print('Task Date: $taskDate');
            final isRecent = taskDate
                .isAfter(DateTime.now().subtract(const Duration(minutes: 30)));
            print('Is Recent: $isRecent');
            return isRecent;
          } catch (e) {
            print('Error parsing date: $e');
            return false; // Return false if there's an error parsing the date
          }
        }).toList();

      case 'completed':
        return addData.where((task) => task['completed'] == true).toList();

      case 'pending':
        return addData.where((task) => task['completed'] == false).toList();

      default:
        return addData; // Returns all tasks
    }
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
      print("Date format error: $e");
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
