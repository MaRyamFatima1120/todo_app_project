
import 'package:get/get.dart';

class MainController extends GetxController{
  var selected =0.obs;

  void onItemTap(int index){
    selected.value=index;
  }

  void updatePageDrawer(int index){
    selected.value=index;
    Get.back();
  }

}