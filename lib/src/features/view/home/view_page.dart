import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/src/common/utils/global_variable.dart';

import '../../../common/utils/validation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textform.dart';
import '../../view-model/home_controller.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final HomeController controller = Get.put(HomeController());

  // Retrieve arguments passed from previous screen

  late int index;
  late String title;
  late String description;
  late String time;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    index = Get.arguments['index'];
    title = controller.addData[index]['title'];
    description = controller.addData[index]['description'];
    time = DateTime.parse(controller.addData[index]['timeStamp']).toIso8601String();
    backgroundColor = Get.arguments['backgroundColor'] ?? Colors.white;
  }

  void _openEditDialog(BuildContext context, int index) {
    final titleController =
    TextEditingController(text: controller.addData[index]['title']);
    final descriptionController =
    TextEditingController(text: controller.addData[index]['description']);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
                  "Edit Task",
                  style: textTheme(context).titleMedium?.copyWith(
                      color: colorScheme(context).onSecondary, fontSize: 24),
                )),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    labelText: "title",
                    keyboard: TextInputType.text,
                    controller: titleController,
                    validator: validateData,
                  ),
                  SizedBox(
                    height: Get.height * 0.03,
                  ),
                  CustomTextFormField(
                    labelText: "Description",
                    maxLines: 4,
                    keyboard: TextInputType.text,
                    controller: descriptionController,
                    validator: validateData,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: textTheme(context).titleSmall?.copyWith(
                      fontSize: 17, color: controller.getIconColor(index)),
                ),
              ),
              SizedBox(
                width: Get.width * 0.005,
              ),
              CustomButton(
                width: 100,
                pressed: () {
                  // Save the edited task details
                  controller.editTask(
                      index, titleController.text, descriptionController.text,);
                  setState(() {
                    // Update the local variables if necessary
                    title = titleController.text;
                    description = descriptionController.text;
                    time = controller.addData[index]['timeStamp'];
                  });
                  Navigator.of(context).pop();
                },
                bgColor: controller.getIconColor(index),
                child: Text(
                  "Edit",
                  style: textTheme(context)
                      .titleSmall
                      ?.copyWith(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  void _deleteDialog(BuildContext context, int index) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: "Delete Task",
      titleStyle: textTheme(context).titleSmall?.copyWith(
        color: colorScheme(context).onSecondary,
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            Text(
              "Are You sure you want to delete this task? ",
              style: textTheme(context).titleSmall?.copyWith(
                  color: colorScheme(context).onSecondary.withOpacity(0.7),
                  fontSize: 12),
            ),
            Text(title.toUpperCase(),
                style: textTheme(context).titleSmall?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: textTheme(context)
                .titleSmall
                ?.copyWith(fontSize: 16, color: controller.getIconColor(index)),
          ),
        ),
        SizedBox(
          width: Get.width * 0.005,
        ),
        CustomButton(
          width: 100,
          height: 40,
          pressed: () {
            controller.deleteData(index);
            Navigator.of(context).pop();
            Get.back();
          },
          bgColor: controller.getIconColor(index),
          child: Text(
            "Delete",
            style: textTheme(context)
                .titleSmall
                ?.copyWith(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        leadingWidth: 25,


        actions: [
          Obx(()=>
             IconButton(
              onPressed: () {
                controller.toggleTaskCompletion(controller.addData[index]['id']);
              },
              icon: Icon(
                controller.addData[index]['completed'] ? Icons.check_circle : Icons.circle_outlined,
                color: Colors.white
              ),
            ),
          ),

          //edit Button
          IconButton(
              onPressed: () {
                _openEditDialog(context, index);
              },
              icon: const Icon(Icons.edit)),

          IconButton(
              onPressed: () {
                _deleteDialog(context, index);
              },
              icon: const Icon(
                Icons.delete,
              )),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: textTheme(context).bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                      width: Get.width * 0.25,
                      height: Get.height * 0.035,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      child: Obx(()=>
                          Center(
                            child: Text(
                              controller.addData[index]['completed'] == true
                                  ? "Completed"
                                  : "Pending",
                              style: textTheme(context).titleSmall?.copyWith(
                                color: backgroundColor
                              )


                            ),
                          ),
                      ),
                    ),
                  ],
                ),
                Text(
                  controller.formatDate(time), // Display formatted time
                  style: textTheme(context)
                      .titleSmall
                      ?.copyWith(color: colorScheme(context).onPrimary),
                ),


              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              width: Get.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0))),
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: textTheme(context).bodySmall,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

