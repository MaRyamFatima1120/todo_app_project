import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/view-model/filter_chip_widget_controller.dart';
import '../utils/global_variable.dart';

class FilterChipWidget extends StatelessWidget {
  final String chipName;
  final Function(String?) onSelectedFilter;

  const FilterChipWidget({super.key, required this.chipName,required this.onSelectedFilter});



  @override
  Widget build(BuildContext context) {
    FilterChipWidgetController controller = Get.put(FilterChipWidgetController());

    return Obx((){
      bool  isSelected = controller.chipSelected(chipName);
      return  FilterChip(
        padding: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side:BorderSide.none
        ),
        showCheckmark: false,
        label: Text(chipName),
        labelStyle: textTheme(context).bodySmall?.copyWith(
          color: isSelected? Colors.white:colorScheme(context).onSecondary
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        side: BorderSide.none,
        onSelected: (isSelected) {
          controller.filterSelected(isSelected, chipName);
          if (isSelected) {
            onSelectedFilter(chipName.toLowerCase()); // Trigger the callback
          } else {
            onSelectedFilter('all'); // Reset filter when unselected
          }
        },

        selectedColor: colorScheme(context).primary,

      );
    });
  }
}