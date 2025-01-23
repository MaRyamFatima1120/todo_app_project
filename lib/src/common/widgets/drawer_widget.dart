import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/src/features/view-model/home_controller.dart';
import 'package:todo_app/src/features/view-model/main_controller.dart';
import 'package:todo_app/src/features/view-model/profile_page_controller.dart';
import '../constants/app_color.dart';
import '../constants/app_icon.dart';
import '../utils/global_variable.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final HomeController controller = Get.put(HomeController());
  final ProfilePageController profileController =
      Get.put(ProfilePageController());
  final MainController mainController = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Get.width,
            height: Get.height * 0.25,
            decoration: BoxDecoration(
                gradient: Get.find<HomeController>().getGradient(2)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => CircleAvatar(
                      radius: 40,
                      backgroundColor: controller.getIconColor(2),
                      backgroundImage:
                          profileController.firstImageUrl.value == null
                              ? null
                              : FileImage(
                                  File(profileController.firstImageUrl.value!)),
                      child: profileController.firstImageUrl.value == null
                          ? Text(
                              profileController.userName.value.isNotEmpty
                                  ? profileController.userName.value[0]
                                      .toUpperCase()
                                  : '',
                              style: textTheme(context)
                                  .titleMedium
                                  ?.copyWith(color: Colors.white, fontSize: 20),
                            )
                          : null,
                    ),
                  ),
                  Text(
                    "${profileController.userName}",
                    style: textTheme(context)
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  Text(
                    '${profileController.userEmail}',
                    style: textTheme(context).bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color:
                            colorScheme(context).onSecondary.withOpacity(0.7)),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                CustomListTile(
                  title: 'Home',
                  svgIconPath: AppIcon.homeIcon,
                  onTap: () => mainController.updatePageDrawer(0),
                ),
                CustomListTile(
                  title: 'View Task',
                  svgIconPath: AppIcon.workIcon,
                  onTap: () => mainController.updatePageDrawer(1),
                ),
                CustomListTile(
                  title: 'Profile',
                  svgIconPath: AppIcon.profileIcon,
                  onTap: () => mainController.updatePageDrawer(2),
                ),
                CustomListTile(
                  title: 'Setting',
                  svgIconPath: AppIcon.settingIcon,
                  onTap: () => mainController.updatePageDrawer(3),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcon.logoutIcon,
                    width: 24,
                    height: 24,
                  ),
                  title: Text("Log Out",
                      style: textTheme(context)
                          .titleSmall
                          ?.copyWith(color: AppColor.redColor)),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('isLogin', false);
                    Get.offAllNamed("/loginPage");
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
                child: Text("Developed by Maryam Fatima",
                    style: textTheme(context).titleSmall)),
          ),
        ]);
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String svgIconPath;
  final Color iconColor;
  final int? targetTabIndex;
  final Color trailingIconColor;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  final Widget? icon;

  const CustomListTile(
      {super.key,
      required this.title,
      required this.svgIconPath,
      this.iconColor = Colors.grey,
      this.targetTabIndex,
      this.trailingIconColor = Colors.grey,
      this.titleStyle,
      this.onTap,
      this.onTrailingTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        svgIconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
      ),
      title: Text(title, style: textTheme(context).titleSmall),
      onTap: onTap,
      trailing: icon,
    );
  }
}
