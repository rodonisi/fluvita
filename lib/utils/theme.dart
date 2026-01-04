import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff216a4d),
      surfaceTint: Color(0xff216a4d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa9f2cd),
      onPrimaryContainer: Color(0xff005137),
      secondary: Color(0xff4d6357),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcfe9d9),
      onSecondaryContainer: Color(0xff364b40),
      tertiary: Color(0xff3d6373),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc1e9fb),
      onTertiaryContainer: Color(0xff244c5b),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff171d19),
      onSurfaceVariant: Color(0xff404943),
      outline: Color(0xff707973),
      outlineVariant: Color(0xffbfc9c1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8dd5b2),
      primaryFixed: Color(0xffa9f2cd),
      onPrimaryFixed: Color(0xff002114),
      primaryFixedDim: Color(0xff8dd5b2),
      onPrimaryFixedVariant: Color(0xff005137),
      secondaryFixed: Color(0xffcfe9d9),
      onSecondaryFixed: Color(0xff0a1f16),
      secondaryFixedDim: Color(0xffb4ccbd),
      onSecondaryFixedVariant: Color(0xff364b40),
      tertiaryFixed: Color(0xffc1e9fb),
      onTertiaryFixed: Color(0xff001f29),
      tertiaryFixedDim: Color(0xffa5ccde),
      onTertiaryFixedVariant: Color(0xff244c5b),
      surfaceDim: Color(0xffd6dbd6),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ef),
      surfaceContainer: Color(0xffeaefe9),
      surfaceContainerHigh: Color(0xffe4eae4),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f2a),
      surfaceTint: Color(0xff216a4d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff327a5b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff253b30),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b7265),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff103b49),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4c7282),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff0d120f),
      onSurfaceVariant: Color(0xff2f3833),
      outline: Color(0xff4c554f),
      outlineVariant: Color(0xff666f69),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8dd5b2),
      primaryFixed: Color(0xff327a5b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff136044),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b7265),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff435a4e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4c7282),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff335a69),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c2),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ef),
      surfaceContainer: Color(0xffe4eae4),
      surfaceContainerHigh: Color(0xffd9ded8),
      surfaceContainerHighest: Color(0xffcdd3cd),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003322),
      surfaceTint: Color(0xff216a4d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005439),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1b3026),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff384e42),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff01313f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff274e5d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262e29),
      outlineVariant: Color(0xff424b46),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8dd5b2),
      primaryFixed: Color(0xff005439),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b27),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff384e42),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff22372c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff274e5d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0a3746),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab5),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf2ec),
      surfaceContainer: Color(0xffdee4de),
      surfaceContainerHigh: Color(0xffd0d6d0),
      surfaceContainerHighest: Color(0xffc2c8c2),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8dd5b2),
      surfaceTint: Color(0xff8dd5b2),
      onPrimary: Color(0xff003825),
      primaryContainer: Color(0xff005137),
      onPrimaryContainer: Color(0xffa9f2cd),
      secondary: Color(0xffb4ccbd),
      onSecondary: Color(0xff1f352a),
      secondaryContainer: Color(0xff364b40),
      onSecondaryContainer: Color(0xffcfe9d9),
      tertiary: Color(0xffa5ccde),
      onTertiary: Color(0xff073543),
      tertiaryContainer: Color(0xff244c5b),
      onTertiaryContainer: Color(0xffc1e9fb),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffdee4de),
      onSurfaceVariant: Color(0xffbfc9c1),
      outline: Color(0xff8a938c),
      outlineVariant: Color(0xff404943),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff216a4d),
      primaryFixed: Color(0xffa9f2cd),
      onPrimaryFixed: Color(0xff002114),
      primaryFixedDim: Color(0xff8dd5b2),
      onPrimaryFixedVariant: Color(0xff005137),
      secondaryFixed: Color(0xffcfe9d9),
      onSecondaryFixed: Color(0xff0a1f16),
      secondaryFixedDim: Color(0xffb4ccbd),
      onSecondaryFixedVariant: Color(0xff364b40),
      tertiaryFixed: Color(0xffc1e9fb),
      onTertiaryFixed: Color(0xff001f29),
      tertiaryFixedDim: Color(0xffa5ccde),
      onTertiaryFixedVariant: Color(0xff244c5b),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b37),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff171d19),
      surfaceContainer: Color(0xff1b211d),
      surfaceContainerHigh: Color(0xff252b28),
      surfaceContainerHighest: Color(0xff303632),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa3ecc7),
      surfaceTint: Color(0xff8dd5b2),
      onPrimary: Color(0xff002c1c),
      primaryContainer: Color(0xff589e7e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc9e2d3),
      onSecondary: Color(0xff142a20),
      secondaryContainer: Color(0xff7e9688),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbbe2f5),
      onTertiary: Color(0xff002a36),
      tertiaryContainer: Color(0xff7096a7),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd5dfd7),
      outline: Color(0xffabb4ad),
      outlineVariant: Color(0xff89938c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff005338),
      primaryFixed: Color(0xffa9f2cd),
      onPrimaryFixed: Color(0xff00150b),
      primaryFixedDim: Color(0xff8dd5b2),
      onPrimaryFixedVariant: Color(0xff003f2a),
      secondaryFixed: Color(0xffcfe9d9),
      onSecondaryFixed: Color(0xff01150c),
      secondaryFixedDim: Color(0xffb4ccbd),
      onSecondaryFixedVariant: Color(0xff253b30),
      tertiaryFixed: Color(0xffc1e9fb),
      onTertiaryFixed: Color(0xff00141b),
      tertiaryFixedDim: Color(0xffa5ccde),
      onTertiaryFixedVariant: Color(0xff103b49),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff404642),
      surfaceContainerLowest: Color(0xff040806),
      surfaceContainerLow: Color(0xff191f1b),
      surfaceContainer: Color(0xff232926),
      surfaceContainerHigh: Color(0xff2e3430),
      surfaceContainerHighest: Color(0xff393f3b),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb9ffdb),
      surfaceTint: Color(0xff8dd5b2),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8ad1ae),
      onPrimaryContainer: Color(0xff000e07),
      secondary: Color(0xffddf6e6),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb0c8b9),
      onSecondaryContainer: Color(0xff000e07),
      tertiary: Color(0xffddf4ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa1c9da),
      onTertiaryContainer: Color(0xff000d13),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe9f2ea),
      outlineVariant: Color(0xffbcc5be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff005338),
      primaryFixed: Color(0xffa9f2cd),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8dd5b2),
      onPrimaryFixedVariant: Color(0xff00150b),
      secondaryFixed: Color(0xffcfe9d9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb4ccbd),
      onSecondaryFixedVariant: Color(0xff01150c),
      tertiaryFixed: Color(0xffc1e9fb),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa5ccde),
      onTertiaryFixedVariant: Color(0xff00141b),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff4b514d),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211d),
      surfaceContainer: Color(0xff2c322e),
      surfaceContainerHigh: Color(0xff373d39),
      surfaceContainerHighest: Color(0xff424844),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  /// Success
  static const success = ExtendedColor(
    seed: Color(0xff1fdc6a),
    value: Color(0xff1fdc6a),
    light: ColorFamily(
      color: Color(0xff34693f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb6f1bb),
      onColorContainer: Color(0xff1b5129),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff34693f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb6f1bb),
      onColorContainer: Color(0xff1b5129),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff34693f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb6f1bb),
      onColorContainer: Color(0xff1b5129),
    ),
    dark: ColorFamily(
      color: Color(0xff9bd4a0),
      onColor: Color(0xff003915),
      colorContainer: Color(0xff1b5129),
      onColorContainer: Color(0xffb6f1bb),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff9bd4a0),
      onColor: Color(0xff003915),
      colorContainer: Color(0xff1b5129),
      onColorContainer: Color(0xffb6f1bb),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff9bd4a0),
      onColor: Color(0xff003915),
      colorContainer: Color(0xff1b5129),
      onColorContainer: Color(0xffb6f1bb),
    ),
  );

  List<ExtendedColor> get extendedColors => [
    success,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
