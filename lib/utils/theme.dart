import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006a6a),
      surfaceTint: Color(0xff006a6a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9cf1f0),
      onPrimaryContainer: Color(0xff004f4f),
      secondary: Color(0xff4a6363),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcce8e7),
      onSecondaryContainer: Color(0xff324b4b),
      tertiary: Color(0xff4b607c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd3e4ff),
      onTertiaryContainer: Color(0xff334863),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff4fbfa),
      onSurface: Color(0xff161d1d),
      onSurfaceVariant: Color(0xff3f4948),
      outline: Color(0xff6f7979),
      outlineVariant: Color(0xffbec9c8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3231),
      inversePrimary: Color(0xff80d5d4),
      primaryFixed: Color(0xff9cf1f0),
      onPrimaryFixed: Color(0xff002020),
      primaryFixedDim: Color(0xff80d5d4),
      onPrimaryFixedVariant: Color(0xff004f4f),
      secondaryFixed: Color(0xffcce8e7),
      onSecondaryFixed: Color(0xff051f1f),
      secondaryFixedDim: Color(0xffb0cccb),
      onSecondaryFixedVariant: Color(0xff324b4b),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff041c35),
      tertiaryFixedDim: Color(0xffb3c8e8),
      onTertiaryFixedVariant: Color(0xff334863),
      surfaceDim: Color(0xffd5dbda),
      surfaceBright: Color(0xfff4fbfa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f4),
      surfaceContainer: Color(0xffe9efee),
      surfaceContainerHigh: Color(0xffe3e9e9),
      surfaceContainerHighest: Color(0xffdde4e3),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003d3d),
      surfaceTint: Color(0xff006a6a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff167979),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff213a3a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff587271),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff223751),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5a6e8b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fbfa),
      onSurface: Color(0xff0c1212),
      onSurfaceVariant: Color(0xff2e3838),
      outline: Color(0xff4a5454),
      outlineVariant: Color(0xff656f6f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3231),
      inversePrimary: Color(0xff80d5d4),
      primaryFixed: Color(0xff167979),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005f5f),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff587271),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff405959),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5a6e8b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff415672),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc1c8c7),
      surfaceBright: Color(0xfff4fbfa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f4),
      surfaceContainer: Color(0xffe3e9e9),
      surfaceContainerHigh: Color(0xffd8dedd),
      surfaceContainerHighest: Color(0xffccd3d2),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003232),
      surfaceTint: Color(0xff006a6a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005252),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff173030),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff344e4d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff172d47),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff364a65),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fbfa),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff242e2e),
      outlineVariant: Color(0xff414b4b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3231),
      inversePrimary: Color(0xff80d5d4),
      primaryFixed: Color(0xff005252),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003939),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff344e4d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1e3737),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff364a65),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff1e344e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab9),
      surfaceBright: Color(0xfff4fbfa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f1),
      surfaceContainer: Color(0xffdde4e3),
      surfaceContainerHigh: Color(0xffcfd6d5),
      surfaceContainerHighest: Color(0xffc1c8c7),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff80d5d4),
      surfaceTint: Color(0xff80d5d4),
      onPrimary: Color(0xff003737),
      primaryContainer: Color(0xff004f4f),
      onPrimaryContainer: Color(0xff9cf1f0),
      secondary: Color(0xffb0cccb),
      onSecondary: Color(0xff1b3534),
      secondaryContainer: Color(0xff324b4b),
      onSecondaryContainer: Color(0xffcce8e7),
      tertiary: Color(0xffb3c8e8),
      onTertiary: Color(0xff1c314b),
      tertiaryContainer: Color(0xff334863),
      onTertiaryContainer: Color(0xffd3e4ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1514),
      onSurface: Color(0xffdde4e3),
      onSurfaceVariant: Color(0xffbec9c8),
      outline: Color(0xff889392),
      outlineVariant: Color(0xff3f4948),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e3),
      inversePrimary: Color(0xff006a6a),
      primaryFixed: Color(0xff9cf1f0),
      onPrimaryFixed: Color(0xff002020),
      primaryFixedDim: Color(0xff80d5d4),
      onPrimaryFixedVariant: Color(0xff004f4f),
      secondaryFixed: Color(0xffcce8e7),
      onSecondaryFixed: Color(0xff051f1f),
      secondaryFixedDim: Color(0xffb0cccb),
      onSecondaryFixedVariant: Color(0xff324b4b),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff041c35),
      tertiaryFixedDim: Color(0xffb3c8e8),
      onTertiaryFixedVariant: Color(0xff334863),
      surfaceDim: Color(0xff0e1514),
      surfaceBright: Color(0xff343a3a),
      surfaceContainerLowest: Color(0xff090f0f),
      surfaceContainerLow: Color(0xff161d1d),
      surfaceContainer: Color(0xff1a2121),
      surfaceContainerHigh: Color(0xff252b2b),
      surfaceContainerHighest: Color(0xff2f3636),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff96ebea),
      surfaceTint: Color(0xff80d5d4),
      onPrimary: Color(0xff002b2b),
      primaryContainer: Color(0xff479e9d),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc6e2e1),
      onSecondary: Color(0xff102a29),
      secondaryContainer: Color(0xff7b9695),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffc8deff),
      onTertiary: Color(0xff102740),
      tertiaryContainer: Color(0xff7d92b1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1514),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dede),
      outline: Color(0xffaab4b3),
      outlineVariant: Color(0xff889292),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e3),
      inversePrimary: Color(0xff005151),
      primaryFixed: Color(0xff9cf1f0),
      onPrimaryFixed: Color(0xff001414),
      primaryFixedDim: Color(0xff80d5d4),
      onPrimaryFixedVariant: Color(0xff003d3d),
      secondaryFixed: Color(0xffcce8e7),
      onSecondaryFixed: Color(0xff001414),
      secondaryFixedDim: Color(0xffb0cccb),
      onSecondaryFixedVariant: Color(0xff213a3a),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff001226),
      tertiaryFixedDim: Color(0xffb3c8e8),
      onTertiaryFixedVariant: Color(0xff223751),
      surfaceDim: Color(0xff0e1514),
      surfaceBright: Color(0xff3f4645),
      surfaceContainerLowest: Color(0xff040808),
      surfaceContainerLow: Color(0xff181f1f),
      surfaceContainer: Color(0xff232929),
      surfaceContainerHigh: Color(0xff2d3434),
      surfaceContainerHighest: Color(0xff383f3f),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaafffe),
      surfaceTint: Color(0xff80d5d4),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7cd1d0),
      onPrimaryContainer: Color(0xff000e0e),
      secondary: Color(0xffd9f6f5),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffadc8c7),
      onSecondaryContainer: Color(0xff000e0e),
      tertiary: Color(0xffe9f0ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffafc4e4),
      onTertiaryContainer: Color(0xff000c1c),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1514),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f1),
      outlineVariant: Color(0xffbac5c4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e3),
      inversePrimary: Color(0xff005151),
      primaryFixed: Color(0xff9cf1f0),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff80d5d4),
      onPrimaryFixedVariant: Color(0xff001414),
      secondaryFixed: Color(0xffcce8e7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb0cccb),
      onSecondaryFixedVariant: Color(0xff001414),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffb3c8e8),
      onTertiaryFixedVariant: Color(0xff001226),
      surfaceDim: Color(0xff0e1514),
      surfaceBright: Color(0xff4b5151),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1a2121),
      surfaceContainer: Color(0xff2b3231),
      surfaceContainerHigh: Color(0xff363d3c),
      surfaceContainerHighest: Color(0xff414848),
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

  List<ExtendedColor> get extendedColors => [];
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
