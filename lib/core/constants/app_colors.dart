import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryLight = Color(0xFF6200EA);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color surfaceVariant10 = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color surfaceVariant20 = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color surfaceVariant30 = Color.fromRGBO(0, 0, 0, 0.3);
  static const Color surfaceVariant50 = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color primary10 = Color.fromRGBO(98, 0, 234, 0.1);
  static const Color primary20 = Color.fromRGBO(98, 0, 234, 0.2);
  static const Color primary30 = Color.fromRGBO(98, 0, 234, 0.3);
  static const Color primary50 = Color.fromRGBO(98, 0, 234, 0.5);
  static const Color primary70 = Color.fromRGBO(98, 0, 234, 0.7);
  static const Color primary80 = Color.fromRGBO(98, 0, 234, 0.8);
  static const Color primary90 = Color.fromRGBO(98, 0, 234, 0.9);
  static const Color secondary05 = Color.fromRGBO(3, 218, 198, 0.05);
  static const Color secondary10 = Color.fromRGBO(3, 218, 198, 0.1);
  static const Color secondary20 = Color.fromRGBO(3, 218, 198, 0.2);
  static const Color onSurface50 = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color onSurface60 = Color.fromRGBO(0, 0, 0, 0.6);
  static const Color onSurface70 = Color.fromRGBO(0, 0, 0, 0.7);
  static const Color onSurface80 = Color.fromRGBO(0, 0, 0, 0.8);
  static const Color onSurface90 = Color.fromRGBO(0, 0, 0, 0.9);
  static const Color white20 = Color.fromRGBO(255, 255, 255, 0.2);
  static const Color white30 = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color white70 = Color.fromRGBO(255, 255, 255, 0.7);
  static const Color white90 = Color.fromRGBO(255, 255, 255, 0.9);
  static const Color black05 = Color.fromRGBO(0, 0, 0, 0.05);
  static const Color black10 = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color black20 = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color black54 = Color.fromRGBO(0, 0, 0, 0.54);
  static const Color error10 = Color.fromRGBO(176, 0, 32, 0.1);
  static const Color error20 = Color.fromRGBO(176, 0, 32, 0.2);
  static const Color success = Color(0xFF4CAF50);
  static const Color success10 = Color.fromRGBO(76, 175, 80, 0.1);
  static const Color warning = Color(0xFFFF9800);
  static const Color warning10 = Color.fromRGBO(255, 152, 0, 0.1);
  static const Color info = Color(0xFF2196F3);
  static const Color info10 = Color.fromRGBO(33, 150, 243, 0.1);
  static const List<Color> primaryGradient = [
    Color(0xFF6200EA),
    Color.fromRGBO(98, 0, 234, 0.8),
  ];
  static const List<Color> surfaceGradient = [
    Color.fromRGBO(98, 0, 234, 0.1),
    Color.fromRGBO(3, 218, 198, 0.05),
  ];
  static const List<Color> cardGradient = [
    Color.fromRGBO(98, 0, 234, 0.2),
    Color.fromRGBO(3, 218, 198, 0.1),
  ];
  static const Color shadowLight = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color shadowMedium = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, 0.3);
  static const Color overlayLight = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color overlayMedium = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color overlayDark = Color.fromRGBO(0, 0, 0, 0.54);
  static const Color border10 = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color border20 = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color border30 = Color.fromRGBO(0, 0, 0, 0.3);
  static const Color disabled = Color.fromRGBO(0, 0, 0, 0.38);
  static const Color disabledSurface = Color.fromRGBO(0, 0, 0, 0.12);
  static const Color divider = Color.fromRGBO(0, 0, 0, 0.12);
  static const Color dividerLight = Color.fromRGBO(0, 0, 0, 0.04);
}

extension ThemeColors on BuildContext {
  Color get primary10 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.1);
  Color get primary20 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.2);
  Color get primary30 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.3);
  Color get primary50 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.5);
  Color get primary70 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.7);
  Color get primary80 => Theme.of(this).colorScheme.primary.withValues(alpha: 0.8);
  Color get secondary05 => Theme.of(this).colorScheme.secondary.withValues(alpha: 0.05);
  Color get secondary10 => Theme.of(this).colorScheme.secondary.withValues(alpha: 0.1);
  Color get secondary20 => Theme.of(this).colorScheme.secondary.withValues(alpha: 0.2);
  Color get surface10 => Theme.of(this).colorScheme.surface.withValues(alpha: 0.1);
  Color get surface20 => Theme.of(this).colorScheme.surface.withValues(alpha: 0.2);
  Color get onSurface50 => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.5);
  Color get onSurface60 => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.6);
  Color get onSurface70 => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.7);
  Color get onSurface80 => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.8);
  Color get error10 => Theme.of(this).colorScheme.error.withValues(alpha: 0.1);
  Color get error20 => Theme.of(this).colorScheme.error.withValues(alpha: 0.2);
  Color get outline10 => Theme.of(this).colorScheme.outline.withValues(alpha: 0.1);
  Color get outline20 => Theme.of(this).colorScheme.outline.withValues(alpha: 0.2);
  Color get outline30 => Theme.of(this).colorScheme.outline.withValues(alpha: 0.3);
  Color get success => AppColors.success;
  Color get success10 => AppColors.success.withValues(alpha: 0.1);
  Color get warning => AppColors.warning;
  Color get warning10 => AppColors.warning.withValues(alpha: 0.1);
  Color get info => AppColors.info;
  Color get info10 => AppColors.info.withValues(alpha: 0.1);
  Color get white => Colors.white;
  Color get white20 => Colors.white.withValues(alpha: 0.2);
  Color get white30 => Colors.white.withValues(alpha: 0.3);
  Color get white70 => Colors.white.withValues(alpha: 0.7);
  Color get white90 => Colors.white.withValues(alpha: 0.9);
  Color get black => Colors.black;
  Color get black05 => Colors.black.withValues(alpha: 0.05);
  Color get black10 => Colors.black.withValues(alpha: 0.1);
  Color get black20 => Colors.black.withValues(alpha: 0.2);
  Color get black54 => Colors.black.withValues(alpha: 0.54);
  Color get shadowLight => Colors.black.withValues(alpha: 0.1);
  Color get shadowMedium => Colors.black.withValues(alpha: 0.2);
  Color get shadowDark => Colors.black.withValues(alpha: 0.3);
  Color get overlayLight => Colors.black.withValues(alpha: 0.1);
  Color get overlayMedium => Colors.black.withValues(alpha: 0.2);
  Color get overlayDark => Colors.black.withValues(alpha: 0.54);
  Color get border10 => Colors.black.withValues(alpha: 0.1);
  Color get border20 => Colors.black.withValues(alpha: 0.2);
  Color get border30 => Colors.black.withValues(alpha: 0.3);
  Color get disabled => Colors.black.withValues(alpha: 0.38);
  Color get disabledSurface => Colors.black.withValues(alpha: 0.12);
  Color get divider => Colors.black.withValues(alpha: 0.12);
  Color get dividerLight => Colors.black.withValues(alpha: 0.04);
}
