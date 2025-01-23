
import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  SplashController extends GetxController{

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    checkUserLogin();

  }

  void checkUserLogin() async{
    SharedPreferences sp =await SharedPreferences.getInstance();

    bool isLogin =sp.getBool("isLogin")?? false;

    if(isLogin){
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