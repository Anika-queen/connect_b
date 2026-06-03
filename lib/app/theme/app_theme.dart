import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// nipa: update this page
class AppColors {
  const AppColors._();

  static const Color pureBlack = Color(0xFF000000);
  static const Color nearBlack = Color(0xFF262626);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color snow = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFE5E5E5);
  static const Color stone = Color(0xFF737373);
  static const Color midGray = Color(0xFF525252);
  static const Color silver = Color(0xFFA3A3A3);
  static const Color buttonTextDark = Color(0xFF404040);
  static const Color borderLight = Color(0xFFD4D4D4);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final nunito = GoogleFonts.nunito();
    final system = ThemeData.light().textTheme;

    final textTheme = TextTheme(
      headlineLarge: nunito.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w500,
        height: 1.0,
        color: AppColors.pureBlack,
      ),
      headlineMedium: nunito.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        height: 1.11,
        color: AppColors.pureBlack,
      ),
      headlineSmall: nunito.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.pureBlack,
      ),
      titleLarge: nunito.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.pureBlack,
      ),
      titleMedium: system.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.pureBlack,
      ),
      titleSmall: system.titleSmall?.copyWith(
        fontSize: 14,
        color: AppColors.stone,
      ),
      bodyLarge: system.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.56,
        color: AppColors.pureBlack,
      ),
      bodyMedium: system.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.5,
        color: AppColors.pureBlack,
      ),
      bodySmall: system.bodySmall?.copyWith(
        fontSize: 14,
        height: 1.43,
        color: AppColors.stone,
      ),
      labelLarge: system.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.pureBlack,
      ),
      labelMedium: system.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColors.stone,
      ),
      labelSmall: system.labelSmall?.copyWith(
        fontSize: 12,
        color: AppColors.silver,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pureWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pureBlack,
        onPrimary: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.pureBlack,
        secondary: AppColors.lightGray,
        onSecondary: AppColors.nearBlack,
        error: AppColors.stone,
        onError: AppColors.pureWhite,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.pureBlack,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.pureBlack,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(
            color: Color(0x803B82F6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppColors.stone),
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.silver,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.stone,
          fontWeight: FontWeight.w400,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pureBlack,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightGray,
          foregroundColor: AppColors.nearBlack,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: const StadiumBorder(),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.buttonTextDark,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.borderLight),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pureBlack,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightGray),
        ),
        margin: const EdgeInsets.only(bottom: 10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorShape: const StadiumBorder(),
        indicatorColor: AppColors.lightGray,
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.nearBlack,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            );
          }
          return const TextStyle(
            color: AppColors.stone,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.nearBlack, size: 24);
          }
          return const IconThemeData(color: AppColors.stone, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorShape: const StadiumBorder(),
        indicatorColor: AppColors.lightGray,
        backgroundColor: Colors.transparent,
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.nearBlack,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.stone,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
        backgroundColor: AppColors.nearBlack,
        contentTextStyle: TextStyle(
          color: AppColors.pureWhite,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
