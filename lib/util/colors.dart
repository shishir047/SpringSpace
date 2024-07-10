import 'package:flutter/material.dart';

const int greenPrimaryValue = 0xFF013B01;

const Color dialogBackgroundColor = Color.fromARGB(255, 236, 255, 236);

const MaterialColor customGreen = MaterialColor(
  greenPrimaryValue,
  <int, Color>{
    50: Color(0xFFE8F5E9),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF43A047),
    600: Color(0xFF388E3C),
    700: Color(0xFF2E7D32),
    800: Color(0xFF1B5E20),
    900: Color(0xFF013B01),
  },
);

const TextStyle baseTextStyle = TextStyle(color: customGreen);

const TextTheme customTextTheme = TextTheme(
  displayLarge: baseTextStyle,
  displayMedium: baseTextStyle,
  displaySmall: baseTextStyle,
  headlineLarge: baseTextStyle,
  headlineMedium: baseTextStyle,
  headlineSmall: baseTextStyle,
  titleLarge: baseTextStyle,
  titleMedium: baseTextStyle,
  titleSmall: baseTextStyle,
  bodyLarge: baseTextStyle,
  bodyMedium: baseTextStyle,
  bodySmall: baseTextStyle,
  labelLarge: baseTextStyle,
  labelMedium: baseTextStyle,
  labelSmall: baseTextStyle,
);

ThemeData customThemeData = ThemeData(
  primarySwatch: customGreen,
  primaryColor: customGreen,
  scaffoldBackgroundColor: const Color.fromARGB(255, 252, 255, 253),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 252, 255, 253),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: customGreen[100],
      foregroundColor: customGreen[900],
    ),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: customGreen[900],
    unselectedLabelColor: customGreen[700],
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: customGreen, width: 2),
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(greenPrimaryValue),
    textTheme: ButtonTextTheme.primary,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: customGreen[900],
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(greenPrimaryValue)),
    ),
    labelStyle: TextStyle(color: Color(greenPrimaryValue)),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: customGreen[700],
  ),
  textTheme: customTextTheme,
  primaryTextTheme: customTextTheme,
);
