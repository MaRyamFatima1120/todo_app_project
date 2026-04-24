import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/src/common/widgets/custom_button.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/utils/validation.dart';
import '../../../../common/widgets/custom_textform.dart';
import '../../../view-model/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _user = TextEditingController();
  final _password = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  bool _obscureText = true;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
                margin: EdgeInsets.symmetric(
                  horizontal: Get.width * 0.05,
                  vertical: Get.height * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Create Account",
                        style: textTheme(context).titleMedium?.copyWith(
                            fontSize: 24,
                            color: colorScheme(context).onSecondary)),
                    Text(
                      "Become New User",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF878787),
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme(context).primary,
                                child: const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            icon: const Icon(Icons.person_outline),
                            labelText: "User Name",
                            keyboard: TextInputType.text,
                            validator: validateData,
                            controller: _user,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            maxLines: 1,
                            icon: const Icon(Icons.email_outlined),
                            labelText: "Email Address",
                            keyboard: TextInputType.emailAddress,
                            controller: _email,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 20),
                          OverflowBar(
                            spacing: 4.0,
                            alignment: MainAxisAlignment.start,
                            overflowAlignment: OverflowBarAlignment.start,
                            children: [
                              CustomTextFormField(
                                icon: const Icon(Icons.key),
                                labelText: "Password",
                                keyboard: TextInputType.text,
                                validator: validatePassword,
                                controller: _password,
                                obscureText: _obscureText,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _obscureText
                                        ? colorScheme(context).onSecondary
                                        : colorScheme(context).primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Obx(() => _authController.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  pressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      await _authController.register(
                                        _email.text.trim(),
                                        _password.text.trim(),
                                        _user.text.trim(),
                                        imageFile: _image,
                                      );
                                    }
                                  },
                                  bgColor: colorScheme(context).primary,
                                  width: Get.width,
                                  child: Text(
                                    "Register",
                                    style: textTheme(context).bodyMedium,
                                  ),
                                )),
                          SizedBox(
                            height: Get.height * 0.025,
                          ),
                          Center(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                text: "Have an Account?",
                                style: textTheme(context).bodySmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              TextSpan(
                                  text: "Login Now",
                                  style: textTheme(context).bodySmall?.copyWith(
                                      color: colorScheme(context).primary,
                                      fontWeight: FontWeight.w700),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.offAllNamed("/loginPage");
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
    )));
  }
}
