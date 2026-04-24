import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/supabase_service.dart';

class FeedbackController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  
  var isLoading = false.obs;
  var userName = ''.obs;
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      email.value = user.email ?? '';
      final profile = await _supabaseService.getUserProfile(user.id);
      if (profile != null) {
        userName.value = profile['username'] ?? '';
      }
    }
  }

  Future<void> submitFeedback({
    required String userName,
    required String email,
    required String description,
  }) async {
    if (userName.isEmpty || email.isEmpty || description.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    final feedbackData = {
      'user_name': userName,
      'email': email,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    };

    final success = await _supabaseService.submitFeedback(feedbackData);
    
    isLoading.value = false;

    if (success) {
      Get.defaultDialog(
        title: "Success!",
        middleText: "Thank you for your feedback! It has been submitted successfully.",
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        middleTextStyle: const TextStyle(color: Colors.black87),
        confirm: TextButton(
          onPressed: () {
            Get.back(); // Close dialog
            Get.back(); // Go back to settings page
          },
          child: const Text("OK", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
        barrierDismissible: false,
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to submit feedback. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
