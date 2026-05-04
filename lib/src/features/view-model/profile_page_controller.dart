import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/global_variable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/utils/supabase_service.dart';
import '../../common/utils/snack_bar_custom.dart';

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

        CustomSnackBar.success("Account name updated successfully!");
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
      CustomSnackBar.error("Failed to update name: $e");
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
      CustomSnackBar.success("Password updated successfully!");
    } catch (e) {
      debugPrint('Error updating password: $e');
      CustomSnackBar.error("Failed to update password: $e");
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
          CustomSnackBar.error("User not logged in!");
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

          CustomSnackBar.success("Background image updated!");
        } else {
          CustomSnackBar.error("Failed to upload image to Storage.");
        }
      } catch (e) {
        debugPrint('Error updating cover: $e');
        CustomSnackBar.error("Something went wrong: $e");
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

            CustomSnackBar.success("Profile image updated!");
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
      titleStyle: textTheme(context).bodyLarge?.copyWith(
            color: colorScheme(context).primary,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
      middleText:
          "Are you sure you want to delete your account? All your tasks and profile data will be permanently removed.",
      middleTextStyle: textTheme(context).bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
      backgroundColor: Colors.white,
      radius: 20.r,
      contentPadding: EdgeInsets.all(25.r),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          try {
            isLoading.value = true;
            final user = _supabaseService.currentUser;
            if (user != null) {
              await _supabaseService.deleteUserAccount(user.id);
              await _supabaseService.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              CustomSnackBar.error("Your account has been successfully removed.", title: "Account Deleted");
              Get.offAllNamed("/loginPage");
            }
          } catch (e) {
            CustomSnackBar.error("Failed to delete account. Please try again later.");
          } finally {
            isLoading.value = false;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme(context).primary,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text("Delete", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
      ),
    );
  }
}
