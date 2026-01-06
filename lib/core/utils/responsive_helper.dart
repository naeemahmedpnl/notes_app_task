import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DeviceType {
  mobile,
  tablet,
}

class ResponsiveHelper {
  static const double tabletBreakpoint = 600;

  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= tabletBreakpoint
        ? DeviceType.tablet
        : DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
  }) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.mobile ? mobile : tablet;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: EdgeInsets.all(16.w),
      tablet: EdgeInsets.all(24.w),
    );
  }

  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: EdgeInsets.all(8.w),
      tablet: EdgeInsets.all(12.w),
    );
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile.sp,
      tablet: tablet.sp,
    );
  }

  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: BorderRadius.circular(12.r),
      tablet: BorderRadius.circular(16.r),
    );
  }

  static double getResponsiveElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2.0,
      tablet: 4.0,
    );
  }

  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 20.w,
      tablet: 24.w,
    );
  }

  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8.w,
      tablet: 12.w,
    );
  }

  static int getGridCrossAxisCount(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2,
      tablet: 3,
    );
  }

  static double getResponsiveContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValue(
      context,
      mobile: screenWidth * 0.95,
      tablet: screenWidth * 0.85,
    );
  }

  static double getResponsiveAspectRatio(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 0.85,
      tablet: 0.9,
    );
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.tabletBreakpoint) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

extension ResponsiveExtension on BuildContext {
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  BorderRadius get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
  double get responsiveIconSize => ResponsiveHelper.getResponsiveIconSize(this);
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
}
