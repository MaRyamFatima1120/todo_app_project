import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/constants/app_color.dart';
import '../../common/constants/app_icon.dart';
import '../../common/utils/global_variable.dart';
import '../../common/utils/validation.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_textform.dart';
import '../view-model/home_controller.dart';
import '../view-model/main_controller.dart';
import 'home/home_page.dart';
import 'home/profile_page.dart';
import 'home/Setting/setting.dart';
import 'home/task_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainController mainController = Get.put(MainController());
  HomeController homeController = Get.put(HomeController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<Widget> _pages = [
    const Homepage(),
    const TaskView(),
    const ProfilePage(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => _pages[mainController.selected.value]),
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    width: 1.sw,
                    height: 0.5.sh,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Add Task ",
                                style: textTheme(context).bodyMedium?.copyWith(
                                    color: colorScheme(context).onSecondary),
                              ),
                              SizedBox(
                                width: 0.25.sw,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 20.sp,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                          CustomTextFormField(
                            labelText: "title",
                            keyboard: TextInputType.text,
                            controller: titleController,
                            validator: validateData,
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextFormField(
                            labelText: "Write Something Here...",
                            maxLines: 4,
                            keyboard: TextInputType.text,
                            controller: descriptionController,
                            validator: validateData,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) {
                              if (_formKey.currentState!.validate()) {
                                homeController.title.value =
                                    titleController.text;
                                homeController.description.value =
                                    descriptionController.text;
                                homeController.saveData().then((_) {
                                  titleController.clear();
                                  descriptionController.clear();
                                });
                                Get.back();
                              }
                            },
                          ),
                          GestureDetector(
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColor.blueColor, // Main elements
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                        secondary: AppColor.blueColor, // Selection logic
                                        tertiary: AppColor.blueColor,
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
                                        dialBackgroundColor: Colors.grey[100],
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
                                homeController.reminderTime.value = DateTime(
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
                                color: colorScheme(context)
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: colorScheme(context)
                                        .primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.alarm_rounded,
                                      color: colorScheme(context).primary,
                                      size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Obx(() => Text(
                                          homeController.reminderTime.value ==
                                                  null
                                              ? "Set Reminder"
                                              : "Reminder Set: ${DateFormat.jm().format(homeController.reminderTime.value!)}",
                                          style: textTheme(context)
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                        )),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14.sp,
                                      color: colorScheme(context).primary),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          CustomButton(
                            pressed: () {
                              if (_formKey.currentState!.validate()) {
                                homeController.title.value =
                                    titleController.text;
                                homeController.description.value =
                                    descriptionController.text;
                                homeController.saveData().then((_) {
                                  titleController.clear();
                                  descriptionController.clear();
                                });
                                Get.back();
                              }
                            },
                            bgColor: colorScheme(context).primary,
                            width: 1.sw,
                            child: Text(
                              "Add",
                              style: textTheme(context).bodyMedium,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  isScrollControlled: true,
                  isDismissible: false);
            },
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: mainController.selected.value,
            onTap: mainController.onItemTap,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  AppIcon.homeIcon,
                  width: 30.w,
                  height: 30.h,
                  colorFilter:
                      ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.workIcon,
                    width: 30.w,
                    height: 30.h,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.profileIcon,
                    width: 30.w,
                    height: 30.h,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.settingIcon,
                    width: 30.w,
                    height: 30.h,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
            ],
          ),
        ));
  }
}
