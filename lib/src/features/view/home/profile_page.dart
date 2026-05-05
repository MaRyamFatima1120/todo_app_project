import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/constants/app_color.dart';
import '../../../common/constants/app_icon.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/utils/validation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textform.dart';
import '../../../common/widgets/drawer_widget.dart';
import '../../view-model/home_controller.dart';
import '../../view-model/profile_page_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  HomeController homeController = Get.put(HomeController());
  ProfilePageController profileController = Get.put(ProfilePageController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Obx(
                  () => Container(
                    width: 1.sw,
                    height: 0.35.sh,
                    decoration: BoxDecoration(
                      gradient: homeController.getGradient(2),
                    ),
                    child: profileController.coverUrl.value.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileController.coverUrl.value,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const SizedBox.shrink(),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: homeController.getGradient(2),
                              ),
                            ),
                          )
                        : (profileController.secondImageUrl.value != null
                            ? Image.file(
                                File(profileController.secondImageUrl.value!),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                ),
                Positioned(
                    bottom: 10.h,
                    right: 30.w,
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        child: IconButton(
                            onPressed: () {
                              profileController.uploadSecondImage();
                            },
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              size: 20.sp,
                              color: colorScheme(context)
                                  .onSecondary
                                  .withValues(alpha: 0.7),
                            )),
                      ),
                    )),
                Positioned(
                  bottom: -30.h,
                  left: 10.w,
                  child: Obx(
                    () => CircleAvatar(
                      radius: 62.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60.r,
                        backgroundColor:
                            profileController.avatarUrl.value.isEmpty
                                ? homeController.getIconColor(2)
                                : Colors.white,
                        backgroundImage:
                            profileController.avatarUrl.value.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    profileController.avatarUrl.value)
                                : (profileController.firstImageUrl.value != null
                                    ? FileImage(File(
                                        profileController.firstImageUrl.value!))
                                    : null),
                        child: profileController.avatarUrl.value.isEmpty &&
                                profileController.firstImageUrl.value == null
                            ? Text(
                                profileController.userName.value.isNotEmpty
                                    ? profileController.userName.value[0]
                                        .toUpperCase()
                                    : '',
                                style: textTheme(context).titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 40.sp,
                                    ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: -25.h,
                    left: 90.w,
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                          child: IconButton(
                            onPressed: () {
                              profileController.uploadFirstImage();
                            },
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              size: 22.sp,
                              color: colorScheme(context)
                                  .onSecondary
                                  .withValues(alpha: 0.7),
                            ),
                          )),
                    )),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: 15.w, vertical: 50.h),
                children: [
                  Obx(
                    () => Center(
                      child: Text(
                        "${profileController.userName}",
                        style: textTheme(context)
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Obx(
                    () => Center(
                      child: Text(
                        "${profileController.userEmail}",
                        style: textTheme(context).bodySmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: colorScheme(context)
                                .onSecondary
                                .withValues(alpha: 0.7)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0.035.sh,
                  ),
                  Text("Account",
                      style: textTheme(context).titleSmall?.copyWith(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.greyColor)),
                  CustomListTile(
                    title: 'Change Account Name',
                    svgIconPath: AppIcon.profileIcon,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.greyColor,
                      size: 20.sp,
                    ),
                    onTap: () {
                      final userController = TextEditingController(
                          text: profileController.userName.value);
                      Get.defaultDialog(
                        barrierDismissible: false,
                        title: "Change Account Name",
                        titleStyle: textTheme(context).titleSmall?.copyWith(
                              color: colorScheme(context).onSecondary,
                            ),
                        content: Form(
                          key: _formKey,
                          child: SizedBox(
                            width: 0.6.sw,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextFormField(
                                  icon: const Icon(
                                    Icons.person_outline,
                                  ),
                                  labelText: "User Name",
                                  keyboard: TextInputType.text,
                                  validator: validateData,
                                  controller: userController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: textTheme(context).titleSmall?.copyWith(
                                  fontSize: 16.sp,
                                  color: colorScheme(context).primary),
                            ),
                          ),
                          SizedBox(
                            width: 0.005.sw,
                          ),
                          CustomButton(
                            width: 100.w,
                            height: 40.h,
                            pressed: () {
                              if (_formKey.currentState!.validate()) {
                                profileController
                                    .updateUserName(userController.text);
                                Get.back();
                              }
                            },
                            bgColor: colorScheme(context).primary,
                            child: Text(
                              "Save",
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  CustomListTile(
                    title: 'Change Account Password',
                    svgIconPath: AppIcon.passwordIcon,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.greyColor,
                      size: 20.sp,
                    ),
                    onTap: () {
                      final passwordController = TextEditingController();
                      Get.defaultDialog(
                        barrierDismissible: false,
                        title: "Change Account Password",
                        titleStyle: textTheme(context).titleSmall?.copyWith(
                              color: colorScheme(context).onSecondary,
                            ),
                        content: Form(
                          key: _formKey,
                          child: SizedBox(
                            width: 0.6.sw,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextFormField(
                                  icon: const Icon(
                                    Icons.person_outline,
                                  ),
                                  labelText: "Password",
                                  keyboard: TextInputType.text,
                                  validator: validatePassword,
                                  controller: passwordController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: textTheme(context).titleSmall?.copyWith(
                                  fontSize: 16.sp,
                                  color: colorScheme(context).primary),
                            ),
                          ),
                          SizedBox(
                            width: 0.005.sw,
                          ),
                          CustomButton(
                            width: 100.w,
                            height: 40.h,
                            pressed: () {
                              if (_formKey.currentState!.validate()) {
                                profileController.updateUserPassword(
                                    passwordController.text);
                                Get.back();
                              }
                            },
                            bgColor: colorScheme(context).primary,
                            child: Text(
                              "Save",
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  CustomListTile(
                    title: 'Delete Account',
                    svgIconPath: AppIcon.logoutIcon,
                    iconColor: AppColor.redColor,
                    titleStyle: textTheme(context).titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.redColor,
                        ),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.redColor,
                      size: 16.sp,
                    ),
                    onTap: () => profileController.deleteAccount(context),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
