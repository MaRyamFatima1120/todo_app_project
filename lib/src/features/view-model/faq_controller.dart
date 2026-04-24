import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../common/utils/supabase_service.dart';

class FAQController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  
  var faqContent = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    listenToFAQContent();
  }

  void listenToFAQContent() {
    isLoading.value = true;
    debugPrint('Listening to FAQ stream...');
    
    _subscription = _supabaseService.getFAQsStream().listen((data) {
      debugPrint('FAQ Stream updated: Fetched ${data.length} items.');
      faqContent.value = data;
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('FAQ Stream error: $e');
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // Manual refresh if needed
  Future<void> fetchFAQContent() async {
    // Stream handles it automatically, but this can be used for RefreshIndicator
    listenToFAQContent();
  }
}
