import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../common/constants/app_color.dart';
import '../../../../common/constants/app_icon.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/utils/validation.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_textform.dart';

class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "Help and FeedBack ",
            style:textTheme(context).titleSmall?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.greyColor
            )
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin:const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Flex(
              direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get assistance, share your thoughts, or support our app’s growth.',
              style: textTheme(context).titleSmall,),
              SizedBox(height: Get.height * 0.015),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      icon: const Icon(Icons.person_outline),
                      labelText: "User Name",
                      keyboard: TextInputType.text,
                      validator: validateData,
                      controller: userController,
                    ),
                    SizedBox(height: Get.height * 0.015),
                    CustomTextFormField(
                      maxLines: 1,
                      icon: const Icon(Icons.email_outlined),
                      labelText: "Email Address",
                      keyboard: TextInputType.emailAddress,
                      controller: emailController,
                      validator: validateEmail,
                    ),
                    SizedBox(height: Get.height * 0.015),
                    CustomTextFormField(
                      labelText: "Description",
                      maxLines: 4,
                      keyboard: TextInputType.text,
                      controller: descriptionController,
                      validator: validateData,
                    ),
                    SizedBox(height: Get.height * 0.025),
                    CustomButton(
                      pressed: () {
                          Get.back();
                      },
                      bgColor: colorScheme(context).primary,
                      width: Get.width * 0.8,
                      child: Text(
                        "Submit",
                        style: textTheme(context).bodyMedium,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.025),
              Text('Follow us on social media and share our app with your friends!',style: textTheme(context).titleSmall?.copyWith(fontSize: 11),),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                IconButton(onPressed: (){}, icon: SvgPicture.asset(
                  AppIcon.linkedinIcon,
                  width: 24,
                  height: 24,
                  colorFilter:
                  ColorFilter.mode(colorScheme(context).primary, BlendMode.srcIn),
                ),),
                IconButton(onPressed: (){}, icon: SvgPicture.asset(
                  AppIcon.facebookIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(colorScheme(context).primary, BlendMode.srcIn),
                ),),
                IconButton(onPressed: (){

                }, icon: SvgPicture.asset(
                  AppIcon.instaIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(colorScheme(context).primary, BlendMode.srcIn),
                ),)
              ],),
            ],
            ),


          ),
        ),
      )
    );
  }
}
