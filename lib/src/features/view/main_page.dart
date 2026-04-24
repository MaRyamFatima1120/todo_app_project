import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/common/constants/app_color.dart';
import 'package:todo_app/src/features/view-model/main_controller.dart';
import '../../common/constants/app_icon.dart';
import '../../common/utils/global_variable.dart';
import '../../common/utils/validation.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_textform.dart';
import '../view-model/home_controller.dart';
import 'home/home_page.dart';
import 'home/profile_page.dart';
import 'home/Setting/setting.dart';
import 'home/task_view.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainController mainController = Get.put(MainController());
  HomeController homeController = Get.put(HomeController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<Widget> _pages = [
    const Homepage(),
    const TaskView(),
    const ProfilePage(),
    const SettingPage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => _pages[mainController.selected.value]),
        floatingActionButton: Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: Get.width,
                  height: Get.height * 0.5,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Add Task ",
                              style: textTheme(context)
                                  .bodyMedium
                                  ?.copyWith(color: colorScheme(context).onSecondary),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(width: Get.width * 0.25,),
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.close,
                                    size: 20,color: Colors.black,)),
                          ],
                        ),

                        CustomTextFormField(
                          labelText: "title",
                          keyboard: TextInputType.text,
                          controller: titleController,
                          validator: validateData,
                        ),
                        CustomTextFormField(
                          labelText: "Write Something Here...",
                          maxLines: 4,
                          keyboard: TextInputType.text,
                          controller: descriptionController,
                          validator: validateData,
                        ),
                        CustomButton(
                          pressed: () {
                            if (_formKey.currentState!.validate()) {
                           //Update the controller's observable values with text from controllers
                              homeController.title.value = titleController.text;
                              homeController.description.value =
                                  descriptionController.text;
                              //saveData
                              homeController.saveData().then((_) {
                                titleController.clear();
                                descriptionController.clear();
                              });
                              Get.back();
                            }
                          },
                          bgColor: colorScheme(context).primary,
                          width: Get.width,
                          child: Text(
                            "Add",
                            style: textTheme(context).bodyMedium,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                isScrollControlled: true,
                isDismissible: false
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            // backgroundColor: Colors.pink,
            currentIndex: mainController.selected.value,
            onTap: mainController.onItemTap,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  AppIcon.homeIcon,
                  width: 30,
                  height: 30,
                  colorFilter:
                      ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.workIcon,
                    width: 30,
                    height: 30,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.profileIcon,
                    width: 30,
                    height: 30,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcon.settingIcon,
                    width: 30,
                    height: 30,
                    colorFilter:
                        ColorFilter.mode(AppColor.greyColor, BlendMode.srcIn),
                  ),
                  label: ""),
            ],
          ),
        ));
  }
}
