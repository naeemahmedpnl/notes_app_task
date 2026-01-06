import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green, CupertinoIcons.check_mark_circled);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Theme.of(context).colorScheme.error,
        CupertinoIcons.exclamationmark_circle);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Theme.of(context).colorScheme.primary,
        CupertinoIcons.info_circle);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension SnackBarExtension on BuildContext {
  void showSuccess(String message) => AppSnackBar.success(this, message);
  void showError(String message) => AppSnackBar.error(this, message);
  void showInfo(String message) => AppSnackBar.info(this, message);
}
