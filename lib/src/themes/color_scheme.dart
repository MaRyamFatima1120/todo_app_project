import 'package:flutter/material.dart';


// Light Theme Colors
const Color primaryLight = Color(0xff5a9bfe);
const Color onPrimaryLight = Colors.white;
const Color secondary= Colors.white70;
const Color onSecondary = Color(0xff333333);


ColorScheme lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: primaryLight,
  onPrimary: onPrimaryLight,
  secondary: secondary,
  onSecondary: onSecondary,
  error: Colors.red,
  onError: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);