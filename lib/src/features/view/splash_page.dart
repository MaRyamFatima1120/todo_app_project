import 'package:flutter/material.dart';
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
              SizedBox(height:Get.height * 0.4 ,),
              Image.asset("assets/images/logo.png",width:80,
                height: 80,filterQuality: FilterQuality.high,color: colorScheme(context).primary,
              ),
              SizedBox(height:Get.height * 0.01 ,),
              Text("Todo App",style: textTheme(context).bodyLarge ),
              SizedBox(height:Get.height * 0.2 ,),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                    child: Text("Developed by Maryam Fatima",
                        style: textTheme(context).titleSmall)),
              ),
            ],
          ),
        )

    );
  }
}
