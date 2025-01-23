import 'package:get/get.dart';
import 'package:todo_app/src/features/view/home/Register/forget_page.dart';
import 'package:todo_app/src/features/view/home/Register/login_page.dart';
import 'package:todo_app/src/features/view/home/Register/sign_up_page.dart';
import 'package:todo_app/src/features/view/home/Setting/about_us.dart';
import 'package:todo_app/src/features/view/home/Setting/faq_page.dart';
import 'package:todo_app/src/features/view/home/view_page.dart';
import 'package:todo_app/src/features/view/splash_page.dart';
import '../features/view/home/Setting/help_feedback_page.dart';
import '../features/view/home/home_page.dart';

import '../features/view/home/task_view.dart';
import '../features/view/main_page.dart';

class MyAppRouter {
  static final router = [
    GetPage(name: '/', page: () => const SplashPage(),transition: Transition.zoom),
    GetPage(
        name: "/loginPage",
        page: () => const LoginPage(),
        transition: Transition.fade),
    GetPage(
        name: "/registerPage",
        page: () => const RegisterPage(),
        transition: Transition.fade),
    GetPage(
        name: "/forgetPage",
        page: () => const ForgetPage(),
        transition: Transition.zoom),
    GetPage(
        name: "/taskPage",
        page: () => const TaskView(),
        transition: Transition.fadeIn),
    GetPage(
        name: "/taskPage",
        page: () => const TaskView(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/mainPage',
        page: () => const MainPage(),
        transition: Transition.zoom),
    GetPage(
        name: '/viewPage',
        page: () => ViewPage(),
        transition: Transition.zoom),
    GetPage(
        name: "/HomePage",
        page: () => const Homepage(),
        transition: Transition.zoom),
    GetPage(
        name: "/taskPage",
        page: () => const TaskView(),
        transition: Transition.fadeIn),

    GetPage(
        name: "/aboutPage",
        page: () => const AboutPage(),
        transition: Transition.fade),

    GetPage(
        name: "/faqPage",
        page: () => const FAQPage(),
        transition: Transition.fade),
    GetPage(
        name: "/helpPage",
        page: () =>  HelpFeedbackPage(),
        transition: Transition.fade),

  ];
}
