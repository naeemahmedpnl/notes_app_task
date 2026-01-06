import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernAppTheme {
  // Modern minimalist color palette inspired by top design systems
  static const Color primaryColor = Color(0xFF6366F1); // Modern indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan accent
  static const Color tertiaryColor = Color(0xFF8B5CF6); // Purple accent

  // Ultra clean background system
  static const Color backgroundColor =
      Color(0xFFFCFCFD); // Almost white with subtle warmth
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFFFFFFF); // White cards with shadows
  static const Color overlayColor = Color(0xFFF8FAFC); // Light overlay

  // Text hierarchy - Perfect contrast ratios
  static const Color textPrimary = Color(0xFF0F172A); // Very dark slate
  static const Color textSecondary = Color(0xFF475569); // Medium slate
  static const Color textTertiary = Color(0xFF64748B); // Light slate
  static const Color textDisabled = Color(0xFF94A3B8); // Very light slate

  // Status colors - Modern and accessible
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Border and divider colors
  static const Color borderColor = Color(0xFFE2E8F0); // Light border
  static const Color dividerColor = Color(0xFFF1F5F9); // Very light divider
  static const Color focusBorderColor = primaryColor;

  // Modern shadow colors
  static const Color shadowColor = Color(0x08000000); // Very subtle shadow
  static const Color elevationShadow = Color(0x0A000000); // Card elevation

  //Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: Color(0xFFEEF2FF), // Very light indigo
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFE0F7FA), // Very light cyan
        tertiary: tertiaryColor,
        tertiaryContainer: Color(0xFFF3E8FF), // Very light purple
        surface: surfaceColor,
        surfaceVariant: overlayColor,
        background: backgroundColor,
        error: errorColor,
        errorContainer: Color(0xFFFEF2F2), // Very light red
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onBackground: textPrimary,
        onError: Colors.white,
        outline: borderColor,
        outlineVariant: dividerColor,
        shadow: shadowColor,
        scrim: Color(0x80000000),
      ),

      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,

      // App bar theme - Clean and minimal
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: elevationShadow,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card theme - Modern elevated cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: elevationShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(vertical: 4.h),
      ),

      // Input decoration theme - Clean form fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        // Modern border styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),

        // Text styling
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textTertiary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          color: errorColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated button theme - Modern primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // Outlined button theme - Clean secondary buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: borderColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // Floating action button theme - Modern FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 24.w,
      ),
      primaryIconTheme: IconThemeData(
        color: Colors.white,
        size: 24.w,
      ),

      // Text theme - Modern typography scale
      textTheme: TextTheme(
        // Display styles - Large headings
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.0,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
          height: 1.3,
        ),

        // Headline styles - Section headings
        headlineLarge: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.4,
        ),

        // Title styles - Card titles, form labels
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: -0.1,
          height: 1.5,
        ),

        // Body styles - Main content text
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.1,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: textTertiary,
          letterSpacing: 0,
          height: 1.5,
        ),

        // Label styles - Buttons, small labels
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.2,
          height: 1.4,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Dialog theme - Modern modal dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shadowColor: elevationShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.1,
          height: 1.5,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        modalElevation: 12,
        shadowColor: elevationShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
      ),

      // Snackbar theme - Modern notifications
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        behavior: SnackBarBehavior.floating,
        // margin: EdgeInsets.all(16.w),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        titleTextStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.1,
        ),
        iconColor: textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return const Color(0xFFF1F5F9);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return borderColor;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: borderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),
    );
  }

  //Dark theme configuration (for future)
  static ThemeData get darkTheme {
    // Dark theme implementation would go here
    // For now, returning light theme
    return lightTheme;
  }

  //Custom color extensions for easy access
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF6366F1,
    <int, Color>{
      50: Color(0xFFF0F3FF),
      100: Color(0xFFE0E7FF),
      200: Color(0xFFC7D2FE),
      300: Color(0xFFA5B4FC),
      400: Color(0xFF818CF8),
      500: Color(0xFF6366F1), // Primary
      600: Color(0xFF4F46E5),
      700: Color(0xFF4338CA),
      800: Color(0xFF3730A3),
      900: Color(0xFF312E81),
    },
  );
}

//Extension for easy theme access
extension ModernThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Quick access to common colors
  Color get primaryColor => colorScheme.primary;
  Color get backgroundColor => colorScheme.background;
  Color get surfaceColor => colorScheme.surface;
  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => colorScheme.onSurfaceVariant;
}
