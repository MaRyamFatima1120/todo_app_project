import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constants/app_color.dart';
import '../../../../common/constants/app_icon.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/widgets/drawer_widget.dart';

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
                  fontSize: 19,
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
              size: 20,
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
              size: 20,
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
                size: 20,
              ),onTap: () {
            Get.toNamed("/helpPage");
          },),
          ListTile(
            leading: SvgPicture.asset(
              AppIcon.logoutIcon,
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(AppColor.redColor, BlendMode.srcIn),
            ),
            title: Text("Logout",
                style: textTheme(context)
                    .titleSmall
                    ?.copyWith(color: AppColor.redColor)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLogin', false);
              Get.offAllNamed("/loginPage");
            },
          )
        ],
      ),
    );
  }
}
