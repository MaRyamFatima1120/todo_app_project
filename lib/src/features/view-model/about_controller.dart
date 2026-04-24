import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../common/utils/supabase_service.dart';

class AboutController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  
  var aboutContent = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    listenToAboutContent();
  }

  void listenToAboutContent() {
    isLoading.value = true;
    debugPrint('Listening to About Us stream...');
    
    _subscription = _supabaseService.getAboutUsStream().listen((data) {
      debugPrint('Stream updated: Fetched ${data.length} items.');
      aboutContent.value = data;
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Stream error: $e');
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // Fallback if needed
  Future<void> fetchAboutContent() async {
     // Stream handles it now, but keeping for RefreshIndicator
  }
}

