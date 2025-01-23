

import 'package:get/get.dart';

class FilterChipWidgetController extends GetxController{
   var selectedFilter = 'all'.obs;

  // Method to update the selected filter based on isSelected and chipName

    void filterSelected(bool isSelected,String chipName){
      if(isSelected){
        selectedFilter.value =chipName;
      }
      else{
        selectedFilter.value ='all';
      }
    }

    //Check method a chip is currently selected

  bool chipSelected(String chipName){
      return selectedFilter.value == chipName;
  }

}