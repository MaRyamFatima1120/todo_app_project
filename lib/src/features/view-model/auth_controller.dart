import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/utils/supabase_service.dart';

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

          Get.snackbar(
              "Success", "Account created and logged in successfully!");
          Get.offAllNamed("/mainPage");
        } else {
          // If email confirmation is on
          Get.snackbar("Success",
              "Account created successfully. Please check your email for verification.");
          Get.offAllNamed("/loginPage");
        }
      }
    } on AuthException catch (e) {
      Get.snackbar("Error", e.message,
          backgroundColor: Colors.red.withValues(alpha: 0.1));
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred",
          backgroundColor: Colors.red.withValues(alpha: 0.1));
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
      Get.snackbar("Error", e.message,
          backgroundColor: Colors.red.withValues(alpha: 0.1));
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred",
          backgroundColor: Colors.red.withValues(alpha: 0.1));
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out logic
  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? email = sp.getString("email");

    // Log the logout event before signing out
    if (email != null) {
      await _supabaseService.logEvent('logout', email);
    }

    await _supabaseService.signOut();
    sp.clear();
    Get.offAllNamed("/loginPage");
  }

  // Forgot Password logic
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _supabaseService.resetPasswordForEmail(email);
      Get.snackbar("Success", "Password reset email has been sent!");
      Get.offAllNamed("/loginPage");
    } on AuthException catch (e) {
      Get.snackbar("Error", e.message,
          backgroundColor: Colors.red.withValues(alpha: 0.1));
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred",
          backgroundColor: Colors.red.withValues(alpha: 0.1));
    } finally {
      isLoading.value = false;
    }
  }
}
