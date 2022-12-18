import 'package:flutter/material.dart';

ThemeData generateTheme(Color seedColor) {
  return ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    useMaterial3: true,
  );
}

List<Color> carColors = [
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.lightBlue,
];
