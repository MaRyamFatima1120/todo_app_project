

import 'package:get/get.dart';

class FilterChipWidgetController extends GetxController{
   var selectedFilter = 'All'.obs;

  // Method to update the selected filter based on isSelected and chipName

    void filterSelected(bool isSelected, String chipName) {
      // Sticky selection: Only update if the chip is being selected.
      // If user tries to unselect an active chip, we do nothing (it stays active).
      if (isSelected) {
        selectedFilter.value = chipName;
      }
    }

    //Check method a chip is currently selected

  bool chipSelected(String chipName){
      return selectedFilter.value == chipName;
  }

}