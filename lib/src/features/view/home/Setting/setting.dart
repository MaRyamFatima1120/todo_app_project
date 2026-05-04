import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constants/app_color.dart';
import '../../../../common/constants/app_icon.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/widgets/drawer_widget.dart';
import '../../../view-model/auth_controller.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Settings",
              style: textTheme(context).titleSmall?.copyWith(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.greyColor)),
        ),
      ),
      body: ListView(
        children: [
          CustomListTile(
            title: 'About Us',
            svgIconPath: AppIcon.aboutIcon,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColor.greyColor,
              size: 20.sp,
            ),
            onTap: () {
              Get.toNamed("/aboutPage");
            },
          ),
          CustomListTile(
            title: 'FAQs',
            svgIconPath: AppIcon.infoIcon,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColor.greyColor,
              size: 20.sp,
            ),
            onTap: () {
              Get.toNamed("/faqPage");
            },
          ),
          CustomListTile(
              title: 'Support & Feedback',
              svgIconPath: AppIcon.flashIcon,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: AppColor.greyColor,
                size: 20.sp,
              ),onTap: () {
            Get.toNamed("/helpPage");
          },),
          ListTile(
            leading: SvgPicture.asset(
              AppIcon.logoutIcon,
              width: 24.w,
              height: 24.h,
              colorFilter:
                  const ColorFilter.mode(AppColor.redColor, BlendMode.srcIn),
            ),
            title: Text("Logout",
                style: textTheme(context)
                    .titleSmall
                    ?.copyWith(color: AppColor.redColor)),
            onTap: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to log out from the app?",
                titleStyle: textTheme(context).bodyLarge?.copyWith(
                      color: colorScheme(context).primary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                middleTextStyle: textTheme(context).bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                backgroundColor: Colors.white,
                radius: 20.r,
                contentPadding: EdgeInsets.all(25.r),
                textConfirm: "Yes, Logout",
                textCancel: "Cancel",
                confirmTextColor: Colors.white,
                cancelTextColor: colorScheme(context).primary,
                buttonColor: colorScheme(context).primary,
                onConfirm: () async {
                  Get.back(); // Close dialog
                  // Use AuthController logout to ensure Supabase session is cleared too
                  Get.find<AuthController>().logout();
                },
              );
            },
          )
        ],
      ),
    );
  }
}
