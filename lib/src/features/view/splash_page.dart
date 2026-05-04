import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/global_variable.dart';
import '../view-model/splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SplashController splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 0.02.sh,
          ),
          Image.asset(
            "assets/images/LOGO copy.png",
            width: 120.w,
            height: 120.h,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(
            height: 0.01.sh,
          ),
          Text("Todo App", style: textTheme(context).bodyLarge),
          SizedBox(
            height: 0.05.sh,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(30.0),
          //   child: Center(
          //       child: Text("Developed by Maryam Fatima",
          //           style: textTheme(context).titleSmall)),
          // ),
        ],
      ),
    ));
  }
}
