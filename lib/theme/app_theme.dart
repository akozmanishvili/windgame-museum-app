import 'package:flutter/material.dart';

/// colors taken from the Windgate Museum of Art logo.
class AppColors {
  AppColors._();

  static const Color orange = Color(0xFFF68026);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  /// for text fields and cards.
  static const Color surface = Color(0xFF141414);
  static const Color border = Color(0xFF3A3A3A);
  static const Color mutedText = Color(0xFFB0B0B0);
  static const Color error = Color(0xFFFF6B6B);
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Gotham';

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(4));

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.orange,
      onPrimary: AppColors.black,
      secondary: AppColors.orange,
      onSecondary: AppColors.black,
      error: AppColors.error,
      onError: AppColors.black,
      surface: AppColors.black,
      onSurface: AppColors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final text = base.textTheme;

    const buttonText = TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 15,
      letterSpacing: 2,
    );
    const buttonShape = RoundedRectangleBorder(borderRadius: _radius);

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.black,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w300,
          color: AppColors.white,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w300,
          color: AppColors.white,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: text.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        bodyMedium: text.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),

      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: const TextStyle(color: AppColors.mutedText),
        floatingLabelStyle: const TextStyle(color: AppColors.orange),
        helperStyle: const TextStyle(color: AppColors.mutedText),
        errorStyle: const TextStyle(color: AppColors.error),
        errorMaxLines: 2,
        helperMaxLines: 2,
        prefixIconColor: AppColors.mutedText,
        suffixIconColor: AppColors.mutedText,
        border: outline(AppColors.border),
        enabledBorder: outline(AppColors.border),
        focusedBorder: outline(AppColors.orange, 1.5),
        errorBorder: outline(AppColors.error),
        focusedErrorBorder: outline(AppColors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.black,
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orange,
          side: const BorderSide(color: AppColors.orange),
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.orange,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.orange,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.orange,
        selectionColor: AppColors.orange.withValues(alpha: 0.4),
        selectionHandleColor: AppColors.orange,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.white,
          fontSize: 14,
        ),
        actionTextColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A2A)),
    );
  }
}
