import 'package:flutter/material.dart';

import '../../../../common/constants/app_color.dart';
import '../../../../common/utils/global_variable.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "About Us",
            style:textTheme(context).titleSmall?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColor.greyColor
            )
        ),
      ),
      body: Container(
        margin:const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
        child: Text("""Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam, qui nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprshenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborurm.
        
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, qui nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
          
          Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
          """,
        style: textTheme(context).titleSmall?.copyWith(color: colorScheme(context).onSecondary,fontWeight: FontWeight.normal  ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
