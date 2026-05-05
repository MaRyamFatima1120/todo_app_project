import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/utils/global_variable.dart';
import '../../../common/widgets/drawer_widget.dart';
import '../../view-model/home_controller.dart';
import '../../view-model/main_controller.dart';
import '../../view-model/profile_page_controller.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeController controller = Get.put(HomeController());
  ProfilePageController profileController = Get.put(ProfilePageController());
  final MainController mainController = Get.put(MainController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                                width: 0.6.sw,
                              ),
                              Obx(
                                () => CircleAvatar(
                                  radius: 25.r,
                                  backgroundColor:
                                      profileController.avatarUrl.value.isEmpty
                                          ? controller.getIconColor(2)
                                          : Colors.white,
                                  backgroundImage: profileController
                                          .avatarUrl.value.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          profileController.avatarUrl.value)
                                      : null,
                                  child:
                                      profileController.avatarUrl.value.isEmpty
                                          ? Text(
                                              profileController
                                                      .userName.value.isNotEmpty
                                                  ? profileController
                                                      .userName.value[0]
                                                      .toUpperCase()
                                                  : '',
                                              style: textTheme(context)
                                                  .titleMedium
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 20.sp),
                                            )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 0.01.sh,
                          ),
                          Obx(
                            () => Text(
                              "Hi,${profileController.userName}",
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
                                    .withValues(alpha: 0.7)),
                          ),
                          SizedBox(
                            height: 0.04.sh,
                          ),
                          SearchBar(
                            focusNode: _focusNode,
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0)),
                            shape:
                                WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
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
                            height: 48.h, // 0.06.sh approx
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
                                      fontSize: 18.sp),
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
                                              color: colorScheme(context).primary,
                                            ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            SizedBox(
                              height: 0.3.sh,
                              child: Obx(() {
                                if (controller.searchData.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/images/home.png",
                                        fit: BoxFit.contain,
                                        width: 1.sw,
                                        height: 0.23.sh,
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
                                                        'taskId': item['id'],
                                                        'backgroundColor':
                                                            controller
                                                                .getGradient(
                                                                    index)
                                                                .colors
                                                                .first,
                                                      });
                                                },
                                                child: Container(
                                                  width: 0.44.sw,
                                                  height: 0.25.sh,
                                                  margin:
                                                      const EdgeInsets.all(4.0),
                                                  decoration: BoxDecoration(
                                                      gradient: controller
                                                          .getGradient(index),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r)),
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
                                                          height: 36.h,
                                                          width: 36.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onPressed: () {
                                                              controller
                                                                  .toggleTaskCompletion(
                                                                      item[
                                                                          'id']);
                                                            },
                                                            icon: Icon(
                                                                isCompleted
                                                                    ? Icons
                                                                        .check_circle
                                                                    : Icons
                                                                        .circle_outlined,
                                                                size: 22.sp,
                                                                color: controller
                                                                    .getIconColor(
                                                                        index)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 0.01.sh,
                                                        ),
                                                        Text(
                                                          item['title']
                                                              .toUpperCase(),
                                                          style: textTheme(context).bodyMedium?.copyWith(
                                                              fontSize: 13.sp,
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
                                                                        12.sp,
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
                                                                          13.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                            IconButton(
                                                                onPressed: () {
                                                                  Get.toNamed(
                                                                      "/viewPage",
                                                                      arguments: {
                                                                        'taskId':
                                                                            item['id'],
                                                                        'backgroundColor': controller
                                                                            .getGradient(index)
                                                                            .colors
                                                                            .first,
                                                                      });
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15.sp,
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
                                  .getTasksByFilter('pending')
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
                                                fontSize: 18.sp,
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
                                                      'taskId': item['id'],
                                                      'backgroundColor':
                                                          controller
                                                              .getGradient(
                                                                  index)
                                                              .colors
                                                              .first,
                                                    });
                                              },
                                              leading: Container(
                                                width: 0.16.sw,
                                                height: 0.07.sh,
                                                decoration: BoxDecoration(
                                                  color: controller
                                                      .getIconColor(index),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0.r),
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
                                                      fontSize: 12.sp,
                                                      color:
                                                          colorScheme(context)
                                                              .onSecondary
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              trailing: IconButton(
                                                onPressed: () {
                                                  controller
                                                      .toggleTaskCompletion(
                                                          item['id']);
                                                },
                                                icon: Icon(
                                                  item['completed'] == true
                                                      ? Icons.check_circle
                                                      : Icons.circle_outlined,
                                                  color: controller
                                                      .getIconColor(index),
                                                ),
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
