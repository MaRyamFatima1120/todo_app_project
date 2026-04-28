import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/utils/supabase_service.dart';

class ProfilePageController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  var firstImageUrl = Rx<String?>(null);
  var secondImageUrl = Rx<String?>(null);
  var coverUrl = "".obs; 
  var avatarUrl = "".obs;
  final ImagePicker imagePicker = ImagePicker();

  RxString userName = "".obs;
  RxString userEmail = "".obs;
  RxString userPassword = "".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  // Load user data from Supabase and local storage
  Future<void> loadUser() async {
    // 1. Instant load from local storage (No awaiting if possible, but SP needs it)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    avatarUrl.value = prefs.getString('cached_avatar_url') ?? '';
    coverUrl.value = prefs.getString('cached_cover_url') ?? '';
    userName.value = prefs.getString('user') ?? 'Guest';
    userEmail.value = prefs.getString('email') ?? '';

    try {
      isLoading.value = true;
      final user = _supabaseService.currentUser;
//...

      if (user != null) {
        userEmail.value = user.email ?? '';
        final data = await _supabaseService.getUserProfile(user.id);

        if (data != null) {
          userName.value = data['username'] ?? 'Guest';
          avatarUrl.value = data['avatar_url'] ?? '';
          coverUrl.value = data['cover_url'] ?? '';

          // 2. Update local storage with latest data from backend
          await prefs.setString('cached_avatar_url', avatarUrl.value);
          await prefs.setString('cached_cover_url', coverUrl.value);
          await prefs.setString('user', userName.value);
        } else {
          userName.value = user.userMetadata?['username'] ?? 'Guest';
        }
      } else {
        userEmail.value = prefs.getString('email') ?? 'Not Provided';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update UserName
  Future<void> updateUserName(String name) async {
    try {
      isLoading.value = true;
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.updateProfileName(user.id, name);
        userName.value = name;
        
        // Update local cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', name);
        
        Get.snackbar("Success", "Account name updated successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
      Get.snackbar("Error", "Failed to update name: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Update Password
  Future<void> updateUserPassword(String password) async {
    try {
      isLoading.value = true;
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: password));
      Get.snackbar("Success", "Password updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      debugPrint('Error updating password: $e');
      Get.snackbar("Error", "Failed to update password: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Compatibility methods for UI
  Future<void> uploadFirstImage() async => uploadProfileImage();

  Future<void> uploadSecondImage() async {
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        isLoading.value = true;
        final user = _supabaseService.currentUser;
        if (user == null) {
          Get.snackbar("Error", "User not logged in!");
          return;
        }

        final file = File(pickedFile.path);
        debugPrint('Uploading cover for user: ${user.id}');
        
        final newUrl = await _supabaseService.uploadCover(user.id, file);

        if (newUrl != null) {
          debugPrint('Cover uploaded successfully: $newUrl');
          await _supabaseService.updateProfileCover(user.id, newUrl);
          coverUrl.value = newUrl;
          secondImageUrl.value = pickedFile.path;
          
          // Save to local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_cover_url', newUrl);
          
          Get.snackbar("Success", "Background image updated!");
        } else {
          Get.snackbar("Error", "Failed to upload image to Storage.");
        }
      } catch (e) {
        debugPrint('Error updating cover: $e');
        Get.snackbar("Error", "Something went wrong: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Upload Profile Image to Supabase
  Future<void> uploadProfileImage() async {
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        isLoading.value = true;
        final user = _supabaseService.currentUser;
        if (user != null) {
          final file = File(pickedFile.path);
          final newUrl = await _supabaseService.uploadAvatar(user.id, file);

          if (newUrl != null) {
            await _supabaseService.updateProfileAvatar(user.id, newUrl);
            avatarUrl.value = newUrl;
            firstImageUrl.value = pickedFile.path;
            
            // Save to local storage
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('cached_avatar_url', newUrl);
            
            Get.snackbar("Success", "Profile image updated!");
          }
        }
      } catch (e) {
        debugPrint('Error updating image: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Delete Account Method
  Future<void> deleteAccount(BuildContext context) async {
    // Professional Confirmation Dialog
    Get.defaultDialog(
      title: "Delete Account",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      middleText: "Are you sure you want to delete your account? All your tasks and profile data will be permanently removed.",
      middleTextStyle: const TextStyle(fontSize: 14),
      backgroundColor: Colors.white,
      radius: 15,
      contentPadding: const EdgeInsets.all(20),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          try {
            isLoading.value = true;
            final user = _supabaseService.currentUser;
            if (user != null) {
              // 1. Delete all user data from Supabase
              await _supabaseService.deleteUserAccount(user.id);
              
              // 2. Sign Out
              await _supabaseService.signOut();
              
              // 3. Clear Local Storage
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              // 4. Success Message & Redirect
              Get.snackbar(
                "Account Deleted", 
                "Your account has been successfully removed.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              );
              
              Get.offAllNamed("/loginPage");
            }
          } catch (e) {
            Get.snackbar(
              "Error", 
              "Failed to delete account. Please try again later.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } finally {
            isLoading.value = false;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Delete", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
