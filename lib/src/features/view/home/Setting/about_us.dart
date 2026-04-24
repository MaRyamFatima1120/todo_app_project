import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/constants/app_color.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../view-model/about_controller.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AboutController controller = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "About Us",
          style: textTheme(context).titleSmall?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColor.greyColor),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.aboutContent.isEmpty) {
          return Center(
            child: Text(
              "No content available.",
              style: textTheme(context).titleSmall,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAboutContent(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            itemCount: controller.aboutContent.length,
            itemBuilder: (context, index) {
              final item = controller.aboutContent[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  item['content'] ?? '',
                  style: textTheme(context).titleSmall?.copyWith(
                      color: colorScheme(context).onSecondary,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.justify,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

