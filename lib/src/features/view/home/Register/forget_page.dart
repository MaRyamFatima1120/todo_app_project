import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot password?",
                    style: textTheme(context).titleMedium?.copyWith(
                      fontSize: 24,
                      color: colorScheme(context).onSecondary
                    )
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    "Enter your email address and we’ll send you confirmation code to reset your password.",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF878787),
                      fontSize: 16,
                      fontWeight: FontWeight.normal
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.025
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
                            height: Get.height * 0.023
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
                                width: Get.width,
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
