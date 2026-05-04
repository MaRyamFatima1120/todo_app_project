import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/src/common/utils/supabase_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_page_controller.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isRecovering = false;

  @override
  void onInit() {
    super.onInit();
    _handleAuthEvents();
    requestPermissions();
    // Wait a bit to see if a deep link triggers an auth event
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isRecovering) {
        checkUserLogin();
      }
    });
  }

  void _handleAuthEvents() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecovering = true;
        // Redirect to reset password page
        Get.offAllNamed("/resetPassword");
      }
    });
  }

  Future<void> requestPermissions() async {
    // Request Notifications, Storage/Photos, and Camera permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.photos,
      Permission.camera,
      Permission.storage,
    ].request();

    print("Permission Statuses: $statuses");
  }

  void checkUserLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    bool isLogin = sp.getBool("isLogin") ?? false;
    final currentUser = _supabaseService.currentUser;

    if (isLogin || currentUser != null) {
      // Pre-initialize Controllers to load data while splash is showing
      Get.put(AuthController(), permanent: true);
      Get.put(ProfilePageController(), permanent: true);

      Timer(const Duration(seconds: 2), () {
        if (!_isRecovering) {
          Get.offAllNamed("/mainPage");
        }
      });
    } else {
      Timer(const Duration(seconds: 2), () {
        if (!_isRecovering) {
          Get.offAllNamed('/loginPage');
        }
      });
    }
  }
}