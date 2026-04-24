import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/utils/validation.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_textform.dart';
import '../../../view-model/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/person.png",
              fit: BoxFit.fitHeight,
              width: Get.width,
              height: Get.height * 0.5,
              filterQuality: FilterQuality.high,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    maxLines: 1,
                    icon: const Icon(Icons.email_outlined),
                    labelText: "Email Address",
                    keyboard: TextInputType.emailAddress,
                    controller: _email,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    icon: const Icon(Icons.key),
                    maxLines: 1,
                    labelText: "Password",
                    keyboard: TextInputType.text,
                    validator: validateData,
                    controller: _password,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: _obscureText
                            ? colorScheme(context).onSecondary
                            : colorScheme(context).primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed("/forgetPage");
                    },
                    child: Text("Forget password?",
                        style: textTheme(context).titleSmall),
                  ),
                  Obx(() => _authController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          pressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _authController.login(
                                _email.text.trim(),
                                _password.text.trim(),
                              );
                            }
                          },
                          bgColor: colorScheme(context).primary,
                          width: Get.width,
                          child: Text(
                            "Log in",
                            style: textTheme(context).bodyMedium,
                          ),
                        )),
                  SizedBox(
                    height: Get.height * 0.025,
                  ),
                  Center(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: "Don't hava an account?",
                        style: textTheme(context).bodySmall?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      TextSpan(
                          text: "Register",
                          style: textTheme(context).bodySmall?.copyWith(
                              color: colorScheme(context).primary,
                              fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offAllNamed("/registerPage");
                            }),
                    ])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )));
  }
}
