import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/utils/supabase_service.dart';

class ProfilePageController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  var firstImageUrl = Rx<String?>(null);
  var secondImageUrl = Rx<String?>(null); // Restore this
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

  // Load user data from Supabase
  Future<void> loadUser() async {
    try {
      isLoading.value = true;
      final user = _supabaseService.currentUser;

      if (user != null) {
        userEmail.value = user.email ?? '';
        final data = await _supabaseService.getUserProfile(user.id);

        if (data != null) {
          userName.value = data['username'] ?? 'Guest';
          avatarUrl.value = data['avatar_url'] ?? '';
        } else {
          userName.value = user.userMetadata?['username'] ?? 'Guest';
        }
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userName.value = prefs.getString('user') ?? 'Guest';
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
    userName.value = name;
    // Optional: Update in Supabase too
    final user = _supabaseService.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'username': name}).eq('id', user.id);
    }
  }

  // Update Password
  Future<void> updateUserPassword(String password) async {
    userPassword.value = password;
    await Supabase.instance.client.auth
        .updateUser(UserAttributes(password: password));
  }

  // Compatibility methods for UI
  Future<void> uploadFirstImage() async => uploadProfileImage();

  Future<void> uploadSecondImage() async {
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      secondImageUrl.value = pickedFile.path;
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
}
