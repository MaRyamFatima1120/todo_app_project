import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../../common/widgets/glass_container.dart';
import '../../../view-model/home_controller.dart';
import '../../../view-model/profile_page_controller.dart';

class HomeHeader extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onMenuPressed;

  const HomeHeader({
    super.key,
    required this.focusNode,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfilePageController>();
    final homeController = Get.find<HomeController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme(context).primary,
            colorScheme(context).primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onMenuPressed,
                child: GlassContainer(
                  padding: EdgeInsets.all(8.r),
                  borderRadius: 12.r,
                  child: Icon(Icons.menu, color: Colors.white, size: 24.sp),
                ),
              ),
              Obx(() => CircleAvatar(
                    radius: 24.r,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: profileController.avatarUrl.value.isNotEmpty
                        ? CachedNetworkImageProvider(profileController.avatarUrl.value)
                        : null,
                    child: profileController.avatarUrl.value.isEmpty
                        ? Text(
                            profileController.userName.value.isNotEmpty
                                ? profileController.userName.value[0].toUpperCase()
                                : 'U',
                            style: textTheme(context).titleMedium?.copyWith(color: Colors.white),
                          )
                        : null,
                  )),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(() => Text(
                "Hi, ${profileController.userName}",
                style: textTheme(context).headlineMedium?.copyWith(color: Colors.white),
              )),
          Text(
            "Ready to conquer your day?",
            style: textTheme(context).bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(height: 25.h),
          GlassContainer(
            borderRadius: 15.r,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: TextField(
              focusNode: focusNode,
              onChanged: homeController.onChangedFunction,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search tasks...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onActionPressed,
    this.actionLabel = "View All",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme(context).titleLarge),
          if (onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionLabel,
                style: textTheme(context).labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class HorizontalTaskCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const HorizontalTaskCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    bool isCompleted = item['completed'] ?? false;

    return GestureDetector(
      onTap: () {
        Get.toNamed("/viewPage", arguments: {
          'taskId': item['id'],
          'backgroundColor': controller.getGradient(index).colors.first,
        });
      },
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(left: 20.w, bottom: 10.h, top: 10.h),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          gradient: controller.getGradient(index),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: controller.getGradient(index).colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.white.withOpacity(0.8), size: 18.sp),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: textTheme(context).titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item['description'] ?? "",
                  style: textTheme(context).bodySmall?.copyWith(color: Colors.white.withOpacity(0.8)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PendingTaskTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const PendingTaskTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        onTap: () {
          Get.toNamed("/viewPage", arguments: {
            'taskId': item['id'],
            'backgroundColor': controller.getGradient(index).colors.first,
          });
        },
        leading: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: controller.getIconColor(index).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              "${index + 1}",
              style: textTheme(context).titleMedium?.copyWith(
                    color: controller.getIconColor(index),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        title: Text(
          item['title'],
          style: textTheme(context).titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          item['description'] ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme(context).bodySmall,
        ),
        trailing: IconButton(
          onPressed: () => controller.toggleTaskCompletion(item['id']),
          icon: Icon(
            item['completed'] == true ? Icons.check_circle : Icons.circle_outlined,
            color: controller.getIconColor(index),
          ),
        ),
      ),
    );
  }
}
