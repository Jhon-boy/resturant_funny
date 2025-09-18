import 'dart:ui';

import 'package:flutter/material.dart';

/// Centralized responsive helpers and breakpoints.
/// Keep logic here to reuse across pages/widgets.
class ResponsiveUtil {
  ResponsiveUtil._();

  static const double smallMaxWidth = 600; // phones
  static const double mediumMaxWidth = 1024; // small tablets
  static const double largeMaxWidth = 1440; // tablets/desktop

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isSmall(BuildContext context) =>
      screenWidth(context) <= smallMaxWidth;
  static bool isMedium(BuildContext context) {
    final width = screenWidth(context);
    return width > smallMaxWidth && width <= mediumMaxWidth;
  }

  static bool isLarge(BuildContext context) {
    final width = screenWidth(context);
    return width > mediumMaxWidth && width <= largeMaxWidth;
  }

  static bool isXL(BuildContext context) =>
      screenWidth(context) > largeMaxWidth;

  /// Compute grid columns based on width. Override with [minTileWidth] if needed.
  static int columnsForGrid(BuildContext context,
      {double minTileWidth = 200, int minColumns = 1, int maxColumns = 6}) {
    final double width = screenWidth(context);
    const double horizontalPadding = 32; // match common padding in pages
    final double available =
        (width - horizontalPadding).clamp(0, double.infinity);
    final int computed =
        (available / minTileWidth).floor().clamp(minColumns, maxColumns);
    return computed;
  }

  /// Decide if we should render un carrusel según el ancho disponible.
  static bool shouldUseCarouselSync(BuildContext context) {
    return screenWidth(context) >= 700;
  }

  static T byWidth<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
    T? xl,
  }) {
    if (isSmall(context)) return small;
    if (isMedium(context)) return medium ?? small;
    if (isLarge(context)) return large ?? medium ?? small;
    return xl ?? large ?? medium ?? small;
  }

  static Size platformWindowSize() =>
      PlatformDispatcher.instance.views.first.physicalSize /
      PlatformDispatcher.instance.views.first.devicePixelRatio;
}
