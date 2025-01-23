import 'package:flutter/material.dart';

import '../../../../common/constants/app_color.dart';
import '../../../../common/utils/global_variable.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "FAQs ",
            style:textTheme(context).titleSmall?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.greyColor
            )
        ),
      ),
      body: ListView(
        padding:const EdgeInsets.all(8.0),
        children: [
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "How do I add a task for the first time?",
                  style: textTheme(context).titleSmall,
                ),
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "On the main screen, tap the Floating Action Button (FAB) to open the Add Task page. Fill in the task details and press Save to add it to your list.",
                      style: textTheme(context).titleSmall?.copyWith(
                        color: colorScheme(context).onSecondary,
                        fontWeight: FontWeight.normal
                      ),
                      textAlign:TextAlign.justify,

                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "Where can I see my saved tasks?",
                  style: textTheme(context).titleSmall,
                ),
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "After adding a task, it will appear in the task list on the main screen. You can tap on any task to view its details.",
                      style: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onSecondary,
                          fontWeight: FontWeight.normal
                      ),
                      textAlign:TextAlign.justify,

                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "How do I edit a task?",
                  style: textTheme(context).titleSmall,
                ),
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Open the task by clicking on it from the main list. Once inside, make your changes and press Save to update the task.",
                      style: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onSecondary,
                          fontWeight: FontWeight.normal
                      ),
                      textAlign:TextAlign.justify,

                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "How do I delete a task?",
                  style: textTheme(context).titleSmall,
                ),
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Tap on a task to open its details page. On the details page, you’ll find an option to delete the task permanently.",
                      style: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onSecondary,
                          fontWeight: FontWeight.normal
                      ),
                      textAlign:TextAlign.justify,

                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "Can I organize my tasks into categories?",
                  style: textTheme(context).titleSmall,
                ),
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Currently, tasks are displayed in one list. In future updates, category options may be added for better organization.",
                      style: textTheme(context).titleSmall?.copyWith(
                          color: colorScheme(context).onSecondary,
                          fontWeight: FontWeight.normal
                      ),
                      textAlign:TextAlign.justify,

                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
