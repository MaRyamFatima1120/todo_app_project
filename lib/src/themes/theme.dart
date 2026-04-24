import 'package:flutter/material.dart';

import 'color_scheme.dart';
import 'text_theme.dart';

ThemeData appTheme(BuildContext context,) {
  return ThemeData(
    colorScheme: lightColorScheme,
    textTheme: customTextTheme(context),
    primaryColor:  lightColorScheme.primary ,
    scaffoldBackgroundColor:  lightColorScheme.surface,
  );
}
