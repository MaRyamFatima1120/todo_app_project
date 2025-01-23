import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/features/view-model/main_controller.dart';
import '../../../common/constants/app_color.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/widgets/drawer_widget.dart';
import '../../view-model/home_controller.dart';
import '../../view-model/profile_page_controller.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeController controller = Get.put(HomeController());
  ProfilePageController profileController =Get.put(ProfilePageController());
  final MainController mainController=Get.put(MainController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: scaffoldKey,
            drawer:const Drawer(
                backgroundColor: Colors.white,
            child: DrawerWidget(),),
            body: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
              },
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      // color: Colors.pink,
                      image: DecorationImage(
                          image: AssetImage("assets/images/bg.png"),
                          fit: BoxFit.cover),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  scaffoldKey.currentState!.openDrawer();
                                },
                                icon: const Icon(Icons.short_text),
                              ),
                              SizedBox(
                                width: Get.width * 0.6,
                              ),
                              Obx(()=>CircleAvatar(
                                    radius: 25,
                                  backgroundColor:controller.getIconColor(2),
                                  backgroundImage:profileController.firstImageUrl.value== null? null:FileImage(File(profileController.firstImageUrl.value!)),
                                  child: profileController.firstImageUrl.value == null?Text(
                                    profileController.userName.value.isNotEmpty? profileController.userName.value[0].toUpperCase():'',
                                    style: textTheme(context).titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 20
                                    ),
                                  ):null,),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Get.height * 0.01,
                          ),
                          Obx(()=> Text(
                              "Hi,${ profileController.userName}",
                              style: textTheme(context)
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            "Finish your all tasks",
                            style: textTheme(context).bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme(context)
                                    .onSecondary
                                    .withOpacity(0.7)),
                          ),
                          SizedBox(
                            height: Get.height * 0.04,
                          ),
                          SearchBar(
                            focusNode: _focusNode,
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0)),
                            shape:
                            WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // Border color
                            )),
                            hintText: "Search...",
                            hintStyle: WidgetStateProperty.all(
                                textTheme(context).bodySmall),
                            backgroundColor: WidgetStateProperty.all(
                                colorScheme(context).secondary),
                            leading: const Icon(Icons.search),
                            onChanged: controller.onChangedFunction,
                            textStyle: WidgetStateProperty.all(
                                textTheme(context).bodySmall),
                          ),
                          SizedBox(
                            height: Get.height * 0.06,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      //color: Colors.pink,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "My Task",
                                  style: textTheme(context).bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                TextButton(
                                  onPressed: () {
                                    mainController.onItemTap(1);
                                  },
                                  child: Text(
                                    "View All",
                                    style:
                                    textTheme(context).bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.orangeColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: Get.height * 0.3,
                              child: Obx(() {
                                if (controller.searchData.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/images/person.png",
                                        fit: BoxFit.contain,
                                        width: Get.width,
                                        height: Get.height * 0.23,
                                      ),
                                      Text(
                                        "What do you want to do today?",
                                        style: textTheme(context)
                                            .bodySmall
                                            ?.copyWith(
                                            color: colorScheme(context)
                                                .onSecondary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "Tap + to add your tasks",
                                        style: textTheme(context)
                                            .bodySmall
                                            ?.copyWith(
                                            color: colorScheme(context)
                                                .onSecondary),
                                      )
                                    ],
                                  );
                                } else {
                                  return Obx(
                                        () => ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.all(10.0),
                                        itemCount: controller.searchData.length,
                                        itemBuilder: (context, index) {
                                          var item =
                                          controller.searchData[index];
                                          bool isCompleted =
                                              item['completed'] ?? false;
                                          {
                                            return Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.toNamed("/viewPage",
                                                      arguments: {
                                                        'index': index,
                                                        'backgroundColor':
                                                        controller
                                                            .getGradient(
                                                            index)
                                                            .colors
                                                            .first,
                                                      });
                                                },
                                                child: Container(
                                                  width: Get.width * 0.44,
                                                  height: Get.height * 0.25,
                                                  margin:
                                                  const EdgeInsets.all(4.0),
                                                  decoration: BoxDecoration(
                                                      gradient: controller
                                                          .getGradient(index),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        10.0),
                                                    child: Flex(
                                                      direction: Axis.vertical,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          width: 30,
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              controller
                                                                  .toggleTaskCompletion(
                                                                  item['id']);
                                                            },
                                                            icon: Icon(
                                                                isCompleted
                                                                    ? Icons
                                                                    .check_circle
                                                                    : Icons
                                                                    .circle_outlined,
                                                                size: 15,
                                                                color: controller
                                                                    .getIconColor(
                                                                    index)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                          Get.height * 0.01,
                                                        ),
                                                        Text(
                                                          item['title']
                                                              .toUpperCase(),
                                                          style: textTheme(context).bodyMedium?.copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              decoration: isCompleted
                                                                  ? TextDecoration
                                                                  .lineThrough
                                                                  : TextDecoration
                                                                  .none,
                                                              decorationColor:
                                                              colorScheme(
                                                                  context)
                                                                  .onSecondary,
                                                              decorationThickness:
                                                              2),
                                                        ),
                                                        Text(
                                                          item['description'],
                                                          style:
                                                          textTheme(context)
                                                              .bodyMedium
                                                              ?.copyWith(
                                                            fontSize:
                                                            12,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "View",
                                                              style: textTheme(
                                                                  context)
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                  fontSize:
                                                                  13,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            IconButton(
                                                                onPressed: () {
                                                                  Get.toNamed(
                                                                      "/viewPage",
                                                                      arguments: {
                                                                        'index':
                                                                        index,
                                                                        'backgroundColor': controller
                                                                            .getGradient(index)
                                                                            .colors
                                                                            .first,
                                                                      });
                                                                },
                                                                icon:
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ))
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                  );
                                }
                              }),
                            ),
                            Obx(() {
                              var pendingTasks = controller
                                  .applyFilterType('pending')
                                  .where((item) =>
                              item['title'].toLowerCase().contains(
                                  controller.searchQuery.value) ||
                                  item['description']
                                      .toLowerCase()
                                      .contains(
                                      controller.searchQuery.value))
                                  .toList();

                              return pendingTasks.isNotEmpty
                                  ? Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pending Task",
                                    style: textTheme(context)
                                        .bodySmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(10.0),
                                    itemCount: pendingTasks.length,
                                    itemBuilder: (context, index) {
                                      var item = pendingTasks[index];
                                      return ListTile(
                                        onTap: () {
                                          Get.toNamed("/viewPage",
                                              arguments: {
                                                'index': index,
                                                'backgroundColor':
                                                controller
                                                    .getGradient(
                                                    index)
                                                    .colors
                                                    .first,
                                              });
                                        },
                                        leading: Container(
                                          width: Get.width * 0.16,
                                          height: Get.height * 0.07,
                                          decoration: BoxDecoration(
                                            color: controller
                                                .getIconColor(index),
                                            borderRadius:
                                            BorderRadius.circular(
                                                10.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: textTheme(context)
                                                  .titleMedium
                                                  ?.copyWith(
                                                  color:
                                                  Colors.white),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          item['title'].toUpperCase(),
                                          style: textTheme(context)
                                              .titleSmall,
                                        ),
                                        subtitle: Text(
                                          item['description'],
                                          style: textTheme(context)
                                              .titleSmall
                                              ?.copyWith(
                                            fontSize: 12,
                                            color:
                                            colorScheme(context)
                                                .onSecondary
                                                .withOpacity(0.7),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),

                                      );
                                    },
                                  ),
                                ],
                              )
                                  : Container(); // Show nothing if no pending tasks
                            })
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
