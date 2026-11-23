import 'package:flutter/material.dart';

sealed class AppThemes {
  AppThemes._();

  static ValueNotifier<ThemeMode> currentTheme = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );
  static ThemeData get currentThemeData =>
      currentTheme.value == ThemeMode.light ? light : dark;

  static ColorScheme get colorScheme => currentThemeData.colorScheme;

  ///retorna a cor de texto conforme o contraste [c], do mais claro ao mais apagado
  static Color textoContraste(double c) {
    return Color.lerp(colorScheme.surface, colorScheme.inverseSurface, c)!;
  }

  static ThemeData light = ThemeData(
    colorScheme: .fromSeed(
      seedColor: const Color.fromARGB(255, 31, 192, 138),
      secondary: const Color.fromARGB(255, 142, 165, 78),
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    ),
    brightness: Brightness.light,
    extensions: [
      ThemeColorExtension(
        prioBaixa: const Color.fromARGB(255, 29, 207, 35), 
        prioMedia: const Color.fromARGB(255, 255, 191, 0), 
        prioAlta: const Color.fromARGB(255, 233, 23, 23))
      ]
  );

  static ThemeData dark = ThemeData(
    colorScheme: .fromSeed(
      seedColor: const Color.fromARGB(255, 31, 192, 138),
      secondary: const Color.fromARGB(255, 142, 165, 78),
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    ),
    brightness: Brightness.dark,
    extensions: {
      ThemeColorExtension(
        prioBaixa: const Color.fromARGB(255, 94, 202, 97), 
        prioMedia: const Color.fromARGB(255, 247, 194, 35), 
        prioAlta: const Color.fromARGB(255, 248, 100, 100))
    }
  );
}

class ThemeColorExtension extends ThemeExtension<ThemeColorExtension> {
  final Color? prioBaixa;
  final Color? prioMedia;
  final Color? prioAlta;

  ThemeColorExtension({
    required this.prioBaixa,
    required this.prioMedia,
    required this.prioAlta,
  });

  @override
  ThemeExtension<ThemeColorExtension> copyWith({
    Color? prioBaixa,
    Color? prioMedia,
    Color? prioAlta,
  }) {
    return ThemeColorExtension(
      prioBaixa: prioBaixa ?? this.prioBaixa,
      prioMedia: prioMedia ?? this.prioMedia,
      prioAlta: prioAlta ?? this.prioAlta,
    );
  }

  @override
  ThemeExtension<ThemeColorExtension> lerp(
    covariant ThemeExtension<ThemeColorExtension>? other,
    double t,
  ) {
    if (other is! ThemeColorExtension) {
      return this;
    }
    return ThemeColorExtension(
      prioBaixa: Color.lerp(prioBaixa, other.prioBaixa, t),
      prioMedia: Color.lerp(prioMedia, other.prioMedia, t),
      prioAlta: Color.lerp(prioAlta, other.prioAlta, t),
    );
  }
}
