import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final RxBool _obscureText = true.obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.05.sw),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/images/login_image.png",
                            fit: BoxFit.fitHeight,
                            width: 0.8.sw,
                            height: 0.4.sh,
                          ),
                        ),
                        SizedBox(
                          height: 0.05.sh,
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
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: 20.h),
                              Obx(() => CustomTextFormField(
                                    icon: const Icon(Icons.key),
                                    maxLines: 1,
                                    labelText: "Password",
                                    keyboard: TextInputType.text,
                                    validator: validateData,
                                    controller: _password,
                                    obscureText: _obscureText.value,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (value) async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        await _authController.login(
                                          _email.text.trim(),
                                          _password.text.trim(),
                                        );
                                      }
                                    },
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _obscureText.value =
                                            !_obscureText.value;
                                      },
                                      icon: Icon(
                                        _obscureText.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _obscureText.value
                                            ? colorScheme(context).onSecondary
                                            : colorScheme(context).primary,
                                      ),
                                    ),
                                  )),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed("/forgetPage");
                                },
                                child: Text("Forget password?",
                                    style: textTheme(context).titleSmall),
                              ),
                              Obx(() => _authController.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CustomButton(
                                      pressed: () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          await _authController.login(
                                            _email.text.trim(),
                                            _password.text.trim(),
                                          );
                                        }
                                      },
                                      bgColor: colorScheme(context).primary,
                                      width: 1.sw,
                                      child: Text(
                                        "Log in",
                                        style: textTheme(context).bodyMedium,
                                      ),
                                    )),
                              SizedBox(
                                height: 0.025.sh,
                              ),
                              Center(
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "Don't hava an account?",
                                    style: textTheme(context)
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                  TextSpan(
                                      text: "Register",
                                      style: textTheme(context)
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme(context)
                                                  .primary,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
