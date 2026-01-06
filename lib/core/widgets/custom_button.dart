import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButtons {
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
    bool showIcon = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: showIcon
          ? ElevatedButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon ?? CupertinoIcons.check_mark),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(text),
            ),
    );
  }

  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    bool showIcon = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: showIcon
          ? OutlinedButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onPressed == null ? Colors.grey : Colors.blue,
                      ),
                    )
                  : Icon(icon ?? CupertinoIcons.xmark),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(text),
            ),
    );
  }

  static Widget text({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: loading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(text),
    );
  }
}
