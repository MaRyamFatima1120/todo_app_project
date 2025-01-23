import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/common/widgets/drawer_widget.dart';
import 'package:todo_app/src/features/view-model/profile_page_controller.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/widgets/filter_chip_widget.dart';
import '../../view-model/home_controller.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController controller = Get.put(HomeController());
  ProfilePageController profileController = Get.put(ProfilePageController());
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.applyFilterType('all');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          drawer: const Drawer(
            backgroundColor: Colors.white,
            child: DrawerWidget(),
          ),
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
                        Text(
                          "My Task",
                          style: textTheme(context)
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Find your all tasks here.",
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
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            // Border color
                          )),
                          hintText: "Search...",
                          hintStyle: WidgetStateProperty.all(
                              textTheme(context).bodySmall),
                          backgroundColor: WidgetStateProperty.all(
                              colorScheme(context).secondary),
                          leading: const Icon(Icons.search),
                          onChanged: (query) {
                            controller.searchTaskView(query);
                          },
                          textStyle: WidgetStateProperty.all(
                              textTheme(context).bodySmall),
                        ),
                        SizedBox(
                          height: Get.height * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            FilterChipWidget(
                              chipName: 'All',
                              onSelectedFilter: (type) =>
                                  controller.applyFilterType('all'),
                            ),
                            FilterChipWidget(
                              chipName: 'Recently Add',
                              onSelectedFilter: (type) =>
                                  controller.applyFilterType('recent'),
                            ),
                            FilterChipWidget(
                              chipName: 'Pending',
                              onSelectedFilter: (type) =>
                                  controller.applyFilterType('pending'),
                            ),
                            FilterChipWidget(
                              chipName: 'Completed',
                              onSelectedFilter: (type) =>
                                  controller.applyFilterType('completed'),
                            ),
                          ],
                        ),
                      ],
                    ),),),
                Expanded(
                  child: Obx(() {
                    final filteredTasks = controller.taskSearchData();
                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Text(
                          "No Task is ${controller.filteredTask.value[0].toUpperCase()}${controller.filteredTask.value.substring(1)}.",
                          style: textTheme(context).titleSmall,
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          var item = filteredTasks[index];
                          int displayNumber = index + 1;
                          return ListTile(
                            leading: Container(
                              width: Get.width * 0.16,
                              height: Get.height * 0.07,
                              decoration: BoxDecoration(
                                  color: controller.getIconColor(index),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                  child: Text(
                                    "$displayNumber",
                                    style: textTheme(context)
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  )),
                            ),
                            title: Text(
                              item['title'].toUpperCase(),
                              style: textTheme(context).titleSmall,
                            ),
                            subtitle: Text(
                              item['description'],
                              style: textTheme(context).titleSmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme(context)
                                      .onSecondary
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            onTap: () {
                              Get.toNamed("/viewPage", arguments: {
                                'index': index,
                                'backgroundColor':
                                controller.getGradient(index).colors.first,
                              });
                            },
                          );
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          )),
    );
  }
}
