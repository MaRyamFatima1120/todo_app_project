import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/utils/global_variable.dart';
import '../../common/widgets/custom_confirmation_dialog.dart';
import '../../common/utils/supabase_service.dart';
import '../../common/utils/snack_bar_custom.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  var isLoading = false.obs;

  // Sign Up logic
  Future<void> register(String email, String password, String username,
      {File? imageFile}) async {
    try {
      isLoading.value = true;
      final response = await _supabaseService.signUp(email, password, username);

      if (response.user != null) {
        String? avatarUrl;

        // If user selected an image, upload it
        if (imageFile != null) {
          avatarUrl =
              await _supabaseService.uploadAvatar(response.user!.id, imageFile);
        }

        // Create profile in public.profiles table with avatarUrl
        await _supabaseService.createProfile(
            response.user!.id, username, email, avatarUrl);

        // Log the registration event
        await _supabaseService.logEvent('register', email);

        if (response.session != null) {
          // If email confirmation is off, user is logged in immediately
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("email", email);
          sp.setBool("isLogin", true);

          CustomSnackBar.success("Account created and logged in successfully!");
          Get.offAllNamed("/mainPage");
        } else {
          // Save email even if not logged in yet, for the forget page or login field
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("email", email);
          
          // If email confirmation is on
          CustomSnackBar.show(
            title: "Success",
            message: "Account created successfully. Please check your email for verification.",
            icon: Icons.email,
            duration: const Duration(seconds: 5),
          );
          Get.offAllNamed("/loginPage");
        }
      }
    } on AuthException catch (e) {
      CustomSnackBar.error(e.message, title: "Registration Failed");
    } catch (e) {
      CustomSnackBar.error("An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In logic
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _supabaseService.signIn(email, password);

      if (response.user != null) {
        // Log the login event
        await _supabaseService.logEvent('login', email);

        // Save to SharedPreferences for compatibility with existing logic
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString("email", email);
        sp.setBool("isLogin", true);

        Get.offAllNamed("/mainPage");
      }
    } on AuthException catch (e) {
      String message = e.message;
      if (message.toLowerCase().contains("invalid login credentials")) {
        message = "Email or password wrong";
      }
      CustomSnackBar.show(
        title: "Login Failed",
        message: message,
        isError: true,
        icon: Icons.lock_person,
      );
    } catch (e) {
      CustomSnackBar.error("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out logic
  Future<void> logout() async {
    try {
      isLoading.value = true;
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? email = sp.getString("email");

      // Running logEvent and signOut in parallel to save time
      await Future.wait([
        if (email != null) _supabaseService.logEvent('logout', email),
        _supabaseService.signOut(),
      ]);

      // IMPORTANT: Don't use sp.clear() because it deletes the email.
      // We only want to remove session-specific data.
      await sp.remove("isLogin");
      // Keep the email so it can be fetched in ForgetPage
      
      Get.offAllNamed("/loginPage");
    } catch (e) {
      debugPrint("Logout error: $e");
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.remove("isLogin");
      Get.offAllNamed("/loginPage");
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password logic
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _supabaseService.resetPasswordForEmail(email);
      
      Get.dialog(
        CustomConfirmationDialog(
          title: "Email Sent!",
          message: "A password reset link has been sent to $email. Please check your inbox.",
          confirmText: "Back to Login",
          cancelText: "", // Hide cancel button
          icon: Icons.mark_email_read_rounded,
          iconColor: colorScheme(Get.context!).primary,
          onConfirm: () {
            Get.offAllNamed("/loginPage");
          },
        ),
        barrierDismissible: false,
      );
    } on AuthException catch (e) {
      CustomSnackBar.error(e.message, title: "Reset Failed");
    } catch (e) {
      CustomSnackBar.error("An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  // Update Password logic
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _supabaseService.updatePassword(newPassword);
      CustomSnackBar.success("Password updated successfully!");
      Get.offAllNamed("/loginPage");
    } on AuthException catch (e) {
      CustomSnackBar.error(e.message, title: "Update Failed");
    } catch (e) {
      CustomSnackBar.error("An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }
}
