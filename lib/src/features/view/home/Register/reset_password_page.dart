import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/utils/global_variable.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_textform.dart';
import '../../../view-model/auth_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter your new Password';
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Confirm your Password';
    }
    if (value != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Reset Password"),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Set New Password",
                    style: textTheme(context).bodyLarge,
                  ),
                  SizedBox(height: 10.h,),
                  Text(
                    "Your new password must be different from previously used passwords.",
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
                          labelText: "New Password",
                          keyboard: TextInputType.visiblePassword,
                          controller: _passwordController,
                          validator: validatePassword,
                          obscureText: true,
                        ),
                        SizedBox(
                            height: 0.02.sh
                        ),
                        CustomTextFormField(
                          labelText: "Confirm Password",
                          keyboard: TextInputType.visiblePassword,
                          controller: _confirmPasswordController,
                          validator: validateConfirmPassword,
                          obscureText: true,
                        ),
                        SizedBox(
                            height: 0.04.sh
                        ),
                        Obx(() => _authController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                pressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _authController.updatePassword(
                                      _passwordController.text.trim(),
                                    );
                                  }
                                },
                                bgColor: colorScheme(context).primary,
                                width: 1.sw,
                                child: Text(
                                  "Reset Password",
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
