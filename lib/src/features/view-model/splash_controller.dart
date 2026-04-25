
import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/utils/supabase_service.dart';
import 'profile_page_controller.dart';

class  SplashController extends GetxController{

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void onInit() {
    super.onInit();
    checkUserLogin();

  }

  void checkUserLogin() async{
    SharedPreferences sp =await SharedPreferences.getInstance();

    bool isLogin = sp.getBool("isLogin") ?? false;
    final currentUser = _supabaseService.currentUser;

    if(isLogin || currentUser != null){
      // Pre-initialize Profile Controller to load data while splash is showing
      Get.put(ProfilePageController(), permanent: true);
      
      Timer(const Duration(seconds: 3), (){
        Get.offAllNamed("/mainPage");
      });
    }
    else{
      Timer(const Duration(seconds: 3), (){
        Get.offAllNamed('/loginPage');
      });
    }

  }
}