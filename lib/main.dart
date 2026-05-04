import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/routes/route.dart';
import 'package:todo_app/src/themes/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/src/common/constants/supabase_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/common/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo App',
          theme: appTheme(context),
          initialRoute: "/",
          defaultTransition: Transition.fadeIn,
          getPages: MyAppRouter.router,
        );
      },
    );
  }
}
