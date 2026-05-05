import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';import 'package:get/get.dart';
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
            borderRadius: BorderRadius.circular(40.0.r),
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
          if (isSelected) {
            controller.filterSelected(isSelected, chipName);
            onSelectedFilter(chipName.toLowerCase()); // Trigger the callback
          }
          // If isSelected is false (user clicked an already active chip),
          // we do nothing so it remains selected (Sticky behavior).
        },

        selectedColor: colorScheme(context).primary,

      );
    });
  }
}