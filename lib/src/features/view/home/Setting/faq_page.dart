import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/constants/app_color.dart';
import '../../../../common/utils/global_variable.dart';
import '../../../view-model/faq_controller.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final FAQController controller = Get.put(FAQController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("FAQs ",
            style: textTheme(context).titleSmall?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.greyColor)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.faqContent.isEmpty) {
          return Center(
            child: Text(
              "No FAQs available.",
              style: textTheme(context).titleSmall,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchFAQContent(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.faqContent.length,
            itemBuilder: (context, index) {
              final faq = controller.faqContent[index];
              return Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      faq['question'] ?? 'No Question',
                      style: textTheme(context).titleSmall,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          faq['answer'] ?? 'No Answer',
                          style: textTheme(context).titleSmall?.copyWith(
                              color: colorScheme(context).onSecondary,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
