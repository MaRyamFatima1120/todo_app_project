import 'package:flutter/material.dart';

import '../utils/global_variable.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboard;
  final String? labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? icon;
  final IconButton? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  //constructor with named parameter
  const CustomTextFormField(
      {super.key,
        this.controller,
        this.keyboard,
        this.labelText,
        this.obscureText = false,
        this.validator,
        this.icon,
        this.suffixIcon,
        this.maxLines =1,
        this.onChanged

      });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        style: textTheme(context).bodySmall,
        maxLines: maxLines,
        cursorHeight: 20,
        cursorColor: colorScheme(context).onSecondary,
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboard,
        validator: validator,
        obscureText: obscureText,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: true,
          labelStyle: textTheme(context).titleSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: colorScheme(context).onSecondary.withOpacity(0.8),
          ),
          prefixIcon: icon,
          suffixIcon: suffixIcon,
          errorStyle: textTheme(context).titleSmall?.copyWith(
              color: colorScheme(context).error,
              fontSize: 12
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:colorScheme(context).onSecondary,
              )),
          focusedBorder:  OutlineInputBorder(
              borderSide: BorderSide(
                color:colorScheme(context).onSecondary,
              )),
          errorBorder:const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:colorScheme(context).onSecondary,
              )),
        ));
  }
}
