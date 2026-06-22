import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double scaleFactor(BuildContext context) {
    final width = screenWidth(context);
    return (width / 390).clamp(0.85, 1.3);
  }

  static double fontSize(BuildContext context, double baseSize) {
    return baseSize * scaleFactor(context);
  }
}