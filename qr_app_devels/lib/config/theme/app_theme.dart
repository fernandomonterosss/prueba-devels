import 'package:flutter/material.dart';

class AppTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.azulElectrico,
    fontFamily: 'Inter',
    extensions: [textTheme],
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleTextStyle: textTheme.xl.bold,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.superficie;
            }

            return AppColors.azulElectrico;
          },
        ),
        foregroundColor: WidgetStateColor.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.superficie;
            }

            return Colors.white;
          },
        ),
        shape: WidgetStateProperty.resolveWith(
          (states) => ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        padding: WidgetStateProperty.resolveWith(
          (states) => EdgeInsets.all(8),
        ),
        textStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.sm.medium,
        ),
      ),
    ),
  );

}


class AppColors {
  AppColors._();

  static const azulElectrico = Color(0xFF2563EB);
  static const azulMarino = Color(0xFF1E3A8A);
  static const cian = Color(0xFF0EA5E9);
  static const azulClaro = Color(0xFFDBEAFE);
  static const azulOscuro = Color(0xFF172033);
  static const grisAzulado = Color(0xFF64748B);
  static const fondo = Color(0xFFE8EEF7);
  static const superficie = Color(0xFFF7FAFF);
  static const ambar = Color(0xFFFEF3C7);
  static const bordeSuave = Color(0xFFE3E8F4);

}

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  AppTextTheme({
    required this.xs,
    required this.sm,
    required this.base,
    required this.lg,
    required this.xl,
    required this.xl2,
    required this.xl3,
    required this.xl4,
  });

  /// 12px
  final TextStyle xs;

  /// 14px
  final TextStyle sm;

  /// 16px
  final TextStyle base;

  /// 18px
  final TextStyle lg;

  /// 20px
  final TextStyle xl;

  /// 24px
  final TextStyle xl2;

  /// 30px
  final TextStyle xl3;

  /// 36px
  final TextStyle xl4;

  @override
  AppTextTheme copyWith({
    TextStyle? xs,
    TextStyle? sm,
    TextStyle? base,
    TextStyle? lg,
    TextStyle? xl,
    TextStyle? xl2,
    TextStyle? xl3,
    TextStyle? xl4,
  }) {
    return AppTextTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      base: base ?? this.base,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xl2: xl2 ?? this.xl2,
      xl3: xl3 ?? this.xl3,
      xl4: xl4 ?? this.xl4,
    );
  }

  @override
  AppTextTheme lerp(
    ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other is! AppTextTheme) {
      return this;
    }

    return AppTextTheme(
      xs: TextStyle.lerp(xs, other.xs, t)!,
      sm: TextStyle.lerp(sm, other.sm, t)!,
      base: TextStyle.lerp(base, other.base, t)!,
      lg: TextStyle.lerp(lg, other.lg, t)!,
      xl: TextStyle.lerp(xl, other.xl, t)!,
      xl2: TextStyle.lerp(xl2, other.xl2, t)!,
      xl3: TextStyle.lerp(xl3, other.xl3, t)!,
      xl4: TextStyle.lerp(xl4, other.xl4, t)!,
    );
  }
}

final textTheme = AppTextTheme(
  xs: const TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  sm: const TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  base: const TextStyle(
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  lg: const TextStyle(
    fontSize: 18,
    height: 28 / 18,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  xl: const TextStyle(
    fontSize: 20,
    height: 28 / 20,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  xl2: const TextStyle(
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  xl3: const TextStyle(
    fontSize: 30,
    height: 36 / 30,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
  xl4: const TextStyle(
    fontSize: 36,
    height: 40 / 36,
    color: AppColors.azulOscuro,
    leadingDistribution: TextLeadingDistribution.even,
  ),
);

extension AppThemeShortcuts on BuildContext {
  AppTextTheme get text => Theme.of(this).extension<AppTextTheme>()!;
}

extension TextStyleUtils on TextStyle {
  TextStyle get normal => copyWith(fontWeight: FontWeight.normal);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get bolder => copyWith(fontWeight: FontWeight.w800);

  TextStyle get secondary => copyWith(color: AppColors.azulOscuro);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  TextStyle get appFont => copyWith(fontFamily: 'Inter');
}