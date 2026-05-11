import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../common/constants/app_color.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/utils/validation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textform.dart';
import '../../view-model/home_controller.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final HomeController controller = Get.put(HomeController());

  // Retrieve arguments passed from previous screen

  late dynamic taskId;
  late int index;
  late String title;
  late String description;
  late String time;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    taskId = Get.arguments['taskId'];
    // Find the current index of this task in the main data list
    index = controller.addData.indexWhere((task) => task['id'].toString() == taskId.toString());
    
    if (index != -1) {
      title = controller.addData[index]['title'];
      description = controller.addData[index]['description'];
      time = controller.addData[index]['timeStamp'];
    } else {
      // Fallback if task not found
      title = "Task Not Found";
      description = "";
      time = DateTime.now().toIso8601String();
    }
    backgroundColor = Get.arguments['backgroundColor'] ?? Colors.white;
  }

  void _openEditDialog(BuildContext context, int index) {
    // Pre-fill reminder time
    if (controller.addData[index]['reminder_time'] != null) {
      controller.reminderTime.value =
          DateTime.parse(controller.addData[index]['reminder_time']);
    } else {
      controller.reminderTime.value = null;
    }

    final titleController =
        TextEditingController(text: controller.addData[index]['title']);
    final descriptionController =
        TextEditingController(text: controller.addData[index]['description']);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
                  "Edit Task",
                  style: textTheme(context).titleMedium?.copyWith(
                      color: colorScheme(context).onSecondary, fontSize: 24.sp),
                )),
            content: SizedBox(
              width: 300.w,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      labelText: "title",
                      keyboard: TextInputType.text,
                      controller: titleController,
                      validator: validateData,
                    ),
                    SizedBox(
                      height: 0.03.sh,
                    ),
                    CustomTextFormField(
                      labelText: "Description",
                      maxLines: 4,
                      keyboard: TextInputType.text,
                      controller: descriptionController,
                      validator: validateData,
                    ),
                    SizedBox(height: 0.02.sh),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColor.blueColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                  secondary: AppColor.blueColor,
                                ),
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: Colors.white,
                                  hourMinuteTextColor: Colors.black,
                                  hourMinuteColor: Colors.grey[200],
                                  dayPeriodColor: WidgetStateColor.resolveWith((states) => 
                                    states.contains(WidgetState.selected) ? AppColor.blueColor : Colors.white),
                                  dayPeriodTextColor: WidgetStateColor.resolveWith((states) => 
                                    states.contains(WidgetState.selected) ? Colors.white : AppColor.blueColor),
                                  dayPeriodBorderSide: const BorderSide(color: AppColor.blueColor),
                                  dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  dialHandColor: AppColor.blueColor,
                                  dialTextColor: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColor.blueColor,
                                  ),
                                ),
                              ),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    alwaysUse24HourFormat: false),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (pickedTime != null) {
                          DateTime now = DateTime.now();
                          controller.reminderTime.value = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              pickedTime.hour,
                              pickedTime.minute);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: controller
                              .getIconColor(index)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: controller
                                  .getIconColor(index)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm_rounded,
                                color: controller.getIconColor(index),
                                size: 20.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Obx(() => Text(
                                    controller.reminderTime.value == null
                                        ? "Update Reminder"
                                        : "New Reminder: ${controller.formatDate(controller.reminderTime.value!.toIso8601String())}",
                                    style: textTheme(context)
                                        .bodySmall
                                        ?.copyWith(
                                          color: controller.getIconColor(index),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.sp,
                                        ),
                                  )),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 14.sp,
                                color: controller.getIconColor(index)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: textTheme(context).titleSmall?.copyWith(
                      fontSize: 17.sp, color: controller.getIconColor(index)),
                ),
              ),
              SizedBox(
                width: 0.005.sw,
              ),
              CustomButton(
                width: 100.w,
                pressed: () {
                  // Save the edited task details
                  controller.editTask(
                    index,
                    titleController.text,
                    descriptionController.text,
                  );

                  // Update the local variables if necessary
                  title = titleController.text;
                  description = descriptionController.text;
                  time = controller.addData[index]['timeStamp'];

                  Navigator.of(context).pop();
                },
                bgColor: controller.getIconColor(index),
                child: Text(
                  "Edit",
                  style: textTheme(context)
                      .titleSmall
                      ?.copyWith(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  void _deleteDialog(BuildContext context, int index) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: "Delete Task",
      titleStyle: textTheme(context).titleSmall?.copyWith(
        color: colorScheme(context).onSecondary,
      ),
      content: SizedBox(
        width: 300.w,
        child: Column(
          children: [
            Text(
              "Are You sure you want to delete this task? ",
              style: textTheme(context).titleSmall?.copyWith(
                  color: colorScheme(context).onSecondary.withValues(alpha: 0.7),
                  fontSize: 12.sp),
            ),
            Text(title.toUpperCase(),
                style: textTheme(context).titleSmall?.copyWith(fontSize: 12.sp)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: textTheme(context)
                .titleSmall
                ?.copyWith(fontSize: 16.sp, color: controller.getIconColor(index)),
          ),
        ),
        SizedBox(
          width: 0.005.sw,
        ),
        CustomButton(
          width: 100.w,
          height: 40.h,
          pressed: () {
            controller.deleteData(index);
            Navigator.of(context).pop();
            Get.back();
          },
          bgColor: controller.getIconColor(index),
          child: Text(
            "Delete",
            style: textTheme(context)
                .titleSmall
                ?.copyWith(fontSize: 16.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        leadingWidth: 25,


        actions: [
          Obx(() {
            final task = controller.addData.firstWhereOrNull((t) => t['id'].toString() == taskId.toString());
            if (task == null) return const SizedBox.shrink();
            return IconButton(
              onPressed: () {
                controller.toggleTaskCompletion(task['id']);
              },
              icon: Icon(
                task['completed'] ? Icons.check_circle : Icons.circle_outlined,
                color: Colors.white
              ),
            );
          }),

          //edit Button
          IconButton(
              onPressed: () {
                final currentIdx = controller.addData.indexWhere((t) => t['id'].toString() == taskId.toString());
                if (currentIdx != -1) {
                  _openEditDialog(context, currentIdx);
                }
              },
              icon: const Icon(Icons.edit)),

          IconButton(
              onPressed: () {
                final currentIdx = controller.addData.indexWhere((t) => t['id'].toString() == taskId.toString());
                if (currentIdx != -1) {
                   _deleteDialog(context, currentIdx);
                }
              },
              icon: const Icon(
                Icons.delete,
              )),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final task = controller.addData.firstWhereOrNull((t) => t['id'].toString() == taskId.toString());
        if (task == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        
        return Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task['title'].toString().toUpperCase(),
                        style: textTheme(context).bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                        width: 0.25.sw,
                        height: 0.035.sh,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0.r),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            task['completed'] == true
                                ? "Completed"
                                : "Pending",
                            style: textTheme(context).titleSmall?.copyWith(
                              color: backgroundColor
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    task['reminder_time'] != null
                        ? "Reminder: ${controller.formatDate(task['reminder_time'])}"
                        : controller.formatDate(task['timeStamp']),
                    style: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onPrimary,
                          fontWeight: task['reminder_time'] != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(40.0),
                width: 1.sw,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0))),
                child: SingleChildScrollView(
                  child: Text(
                    task['description'] ?? '',
                    style: textTheme(context).bodySmall,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),

          ],
        );
      }),
    );
  }
}

