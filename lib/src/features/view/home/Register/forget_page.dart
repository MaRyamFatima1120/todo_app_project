import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/utils/global_variable.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_textform.dart';
import '../../../view-model/auth_controller.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  State<ForgetPage> createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _email.text = savedEmail;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter your Email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Please Enter a valid email address";
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: 5.h,),
                  Text(
                    "Forgot password?",
                    style: textTheme(context).bodyLarge,
                  ),
                  SizedBox(height: 10.h,),
                  Text(
                    "Enter your email address and we’ll send you confirmation code to reset your password.",
                    style: textTheme(context).bodySmall?.copyWith(
                      color: const Color(0xFF878787),
                      fontWeight: FontWeight.normal
                    ),
                  ),
                  SizedBox(
                    height: 0.025.sh
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTextFormField(
                          labelText: "Email",
                          keyboard: TextInputType.emailAddress,
                          controller: _email,
                          validator: validateEmail,
                        ),
                        SizedBox(
                            height: 0.023.sh
                        ),
                        Obx(() => _authController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                pressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _authController.sendPasswordResetEmail(
                                      _email.text.trim(),
                                    );
                                  }
                                },
                                bgColor: colorScheme(context).primary,
                                width: 1.sw,
                                child: Text(
                                  " Continue",
                                  style: textTheme(context).bodyMedium,
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
