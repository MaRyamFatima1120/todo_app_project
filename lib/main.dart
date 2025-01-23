import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/routes/route.dart';
import 'package:todo_app/src/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: appTheme(context),
      initialRoute: "/",
      defaultTransition: Transition.fadeIn,
      getPages: MyAppRouter.router,


    );
  }
}
