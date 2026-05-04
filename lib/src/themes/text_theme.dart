import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_scheme.dart';


TextTheme customTextTheme(BuildContext context){

  return TextTheme(
    bodyLarge: GoogleFonts.dmSans(
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: lightColorScheme.onSecondary
      )
    ),
      bodyMedium: GoogleFonts.dmSans(
          textStyle: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: lightColorScheme.onPrimary
          )
      ),
      bodySmall: GoogleFonts.dmSans(
          textStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,

              color: lightColorScheme.onSecondary
          )
      )
  );
}