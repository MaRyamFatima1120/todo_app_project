import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/features/view-model/profile_page_controller.dart';
import '../../../common/constants/app_color.dart';
import '../../../common/constants/app_icon.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/utils/validation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textform.dart';
import '../../../common/widgets/drawer_widget.dart';
import '../../view-model/home_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  HomeController homeController = Get.put(HomeController());
  ProfilePageController profileController =Get.put(ProfilePageController());
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
              Obx(()=>
                 Container(
                  width: Get.width,
                  height: Get.height * 0.35,
                  decoration: BoxDecoration(
                      gradient: Get.find<HomeController>().getGradient(2),
                    image: profileController.secondImageUrl.value != null  ? DecorationImage(
                      image: FileImage(File(profileController.secondImageUrl.value!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),),
              ),
              Positioned(
                bottom: 10.0,
                right: 30,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: IconButton(
                          onPressed: () {
                              profileController.uploadSecondImage();
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: colorScheme(context).onSecondary.withOpacity(0.7),
                          )),
                    ),
                  )),
              Positioned(
                  bottom: -30,
                  left: 10,
                  child:
                    Obx(()=> CircleAvatar(
                        radius: 62,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor:homeController.getIconColor(2),
                          backgroundImage:profileController.firstImageUrl.value== null? null:FileImage(File(profileController.firstImageUrl.value!)),
                          child: profileController.firstImageUrl.value == null?Text(
                            profileController.userName.value.isNotEmpty? profileController.userName.value[0].toUpperCase():'',
                            style: textTheme(context).titleMedium?.copyWith(
                             color: Colors.white,
                              fontSize: 40,
                            ),
                          ):null,
                        ),
                      ),
                    ),

                ),
              Positioned(
                    bottom: -25,
                    left: 90,
                    child:CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.6),
                        child:IconButton(
                          onPressed: (){
                            profileController.uploadFirstImage();
                          },
                          icon:Icon(
                                Icons.camera_alt_rounded,
                                size: 22,
                                color: colorScheme(context).onSecondary.withOpacity(0.7),
                              ),
                        )
                      ),
                    )),
            ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 50.0),
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
                        "${ profileController.userEmail}",
                        style: textTheme(context).bodySmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: colorScheme(context)
                                .onSecondary
                                .withOpacity(0.7)),
                      ),
                    ),
                  ),
                  SizedBox(height:Get.height * 0.035 ,),
                  Text("Account",
                      style: textTheme(context).titleSmall?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColor.greyColor)),
                  CustomListTile(
                    title: 'Change Account Name',
                    svgIconPath: AppIcon.profileIcon,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.greyColor,
                      size: 20,
                    ),
                    onTap: (){
                      final userController = TextEditingController();
                      Get.defaultDialog(
                        barrierDismissible: false,
                        title: "Change Account Name",
                        titleStyle: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onSecondary,
                        ),
                        content: Form(
                          key: _formKey,
                          child: SizedBox(
                            width: Get.width * 0.6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextFormField(
                                  icon: const Icon(Icons.person_outline,),
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
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16, color:colorScheme(context).primary),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.005,
                          ),
                          CustomButton(
                            width: 100,
                            height: 40,
                            pressed: () {
                              if(_formKey.currentState!.validate()){
                                profileController.updateUserName(userController.text);
                                Get.back();
                              }
                            },
                            bgColor: colorScheme(context).primary,
                            child: Text(
                              "Save",
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16, color: Colors.white),
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
                      size: 20,
                    ),
                    onTap: (){
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
                            width: Get.width * 0.6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextFormField(
                                  icon: const Icon(Icons.person_outline,),
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
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16, color:colorScheme(context).primary),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.005,
                          ),
                          CustomButton(
                            width: 100,
                            height: 40,
                            pressed: () {
                              if(_formKey.currentState!.validate()){
                                profileController.updateUserPassword(passwordController.text);
                                Get.back();

                              }
                            },
                            bgColor: colorScheme(context).primary,
                            child: Text(
                              "Save",
                              style: textTheme(context)
                                  .titleSmall
                                  ?.copyWith(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                ],
              ),
            )
          ]),
    );
  }
}
