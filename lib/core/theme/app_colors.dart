import 'package:flutter/material.dart';

/// Brand and semantic colors shared by the client application.
class AppColors {
  AppColors._();

  // Brand and status colors remain consistent in both themes.
  static const primary = Color(0xFFFF6900);
  static const primaryDark = Color(0xFFF54900);
  static const primaryDisabled = Color(0xFFFFB680);
  static const onPrimary = Colors.white;
  static const textMutedLight = Color(0xFF6A7282);
  static const success = Color(0xFF00A63E);
  static const successBright = Color(0xFF00C950);
  static const warning = Color(0xFFD08700);
  static const error = Color(0xFFFB2C36);
  static const info = Color(0xFF3B82F6);

  static const light = AppPalette(
    background: Color(0xFFFFF9F5),
    surface: Colors.white,
    field: Color(0xFFF9FAFB),
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF101828),
    textMuted: Color(0xFF6A7282),
    primarySoft: Color(0xFFFFF1E6),
    successSoft: Color(0xFFF0FDF4),
    warningSoft: Color(0xFFFEF9C2),
    errorSoft: Color(0xFFFEF2F2),
    infoSoft: Color(0xFFE8F0FE),
    neutralSoft: Color(0xFFE9EAEE),
    shadow: Color(0x14000000),
  );

  static const dark = AppPalette(
    background: Color(0xFF111720),
    surface: Color(0xFF1B2430),
    field: Color(0xFF252F3C),
    border: Color(0xFF2B3543),
    textPrimary: Color(0xFFF4F6F8),
    textMuted: Color(0xFFAAB3C0),
    primarySoft: Color(0xFF38291E),
    successSoft: Color(0xFF17372B),
    warningSoft: Color(0xFF3C2D1F),
    errorSoft: Color(0xFF3A2025),
    infoSoft: Color(0xFF1E3048),
    neutralSoft: Color(0xFF293544),
    shadow: Color(0x33000000),
  );
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.field,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.primarySoft,
    required this.successSoft,
    required this.warningSoft,
    required this.errorSoft,
    required this.infoSoft,
    required this.neutralSoft,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color field;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color primarySoft;
  final Color successSoft;
  final Color warningSoft;
  final Color errorSoft;
  final Color infoSoft;
  final Color neutralSoft;
  final Color shadow;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? field,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? primarySoft,
    Color? successSoft,
    Color? warningSoft,
    Color? errorSoft,
    Color? infoSoft,
    Color? neutralSoft,
    Color? shadow,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    field: field ?? this.field,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textMuted: textMuted ?? this.textMuted,
    primarySoft: primarySoft ?? this.primarySoft,
    successSoft: successSoft ?? this.successSoft,
    warningSoft: warningSoft ?? this.warningSoft,
    errorSoft: errorSoft ?? this.errorSoft,
    infoSoft: infoSoft ?? this.infoSoft,
    neutralSoft: neutralSoft ?? this.neutralSoft,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      field: Color.lerp(field, other.field, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      neutralSoft: Color.lerp(neutralSoft, other.neutralSoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get appColors =>
      Theme.of(this).extension<AppPalette>() ?? AppColors.light;
}
