import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_color.dart';
import '../utils/global_variable.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final IconData icon;
  final Color iconColor;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "Yes, Logout",
    this.cancelText = "Cancel",
    required this.onConfirm,
    this.icon = Icons.logout_rounded,
    this.iconColor = AppColor.redColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: textTheme(context).bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme(context).bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
            ),
            SizedBox(height: 25.h),
            Row(
              children: [
                if (cancelText.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        cancelText,
                        style: textTheme(context).bodySmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                if (cancelText.isNotEmpty) SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: textTheme(context).bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Yes, Logout",
    String cancelText = "Cancel",
    required VoidCallback onConfirm,
    IconData icon = Icons.logout_rounded,
    Color iconColor = AppColor.redColor,
  }) {
    Get.dialog(
      CustomConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}
