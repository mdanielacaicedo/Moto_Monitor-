import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);

  static const Color accentColor = primaryColor;
  static const Color accentLight = primaryLight;
  static const Color accentDark = primaryDark;

  static const Color successColor = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFD97706);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color infoColor = Color(0xFF0284C7);

  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color outlineColor = Color(0xFFD6DCE8);
  static const Color dividerColor = Color(0xFFCBD5E1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCEBFF),
    onPrimaryContainer: Color(0xFF0F172A),
    secondary: primaryDark,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFC7D2FE),
    onSecondaryContainer: Color(0xFF0F172A),
    tertiary: primaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDCEBFF),
    onTertiaryContainer: Color(0xFF0F172A),
    error: errorColor,
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: surfaceColor,
    onSurface: textPrimary,
    surfaceContainerHighest: Color(0xFFE2E8F0),
    surfaceContainerHigh: Color(0xFFF1F5F9),
    surfaceContainer: Color(0xFFF8FAFC),
    surfaceContainerLow: Color(0xFFFAFAFB),
    surfaceContainerLowest: surfaceColor,
    outline: outlineColor,
    outlineVariant: dividerColor,
    shadow: Color(0x1A0F172A),
    scrim: Color(0x990F172A),
    inverseSurface: Color(0xFF0F172A),
    onInverseSurface: Colors.white,
    inversePrimary: primaryLight,
    surfaceTint: primaryColor,
  );

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      colorScheme: lightColorScheme,
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,
      splashColor: primaryColor.withValues(alpha: 0.10),
      highlightColor: primaryColor.withValues(alpha: 0.06),
      colorScheme: lightColorScheme,
      textTheme: _buildTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _titleLargeStyle.copyWith(color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
        actionsIconTheme: const IconThemeData(color: textPrimary),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1.5,
        shadowColor: lightColorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outlineColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: dividerColor,
          disabledForegroundColor: textTertiary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _labelLargeStyle.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _labelLargeStyle.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _labelLargeStyle.copyWith(color: primaryColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: outlineColor, width: 1.5),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _labelLargeStyle.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineColor, width: 1.25),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineColor, width: 1.25),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        labelStyle: _bodyMediumStyle.copyWith(color: textSecondary),
        hintStyle: _bodyMediumStyle.copyWith(color: textTertiary),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryColor;
          return textSecondary;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryColor;
          return textSecondary;
        }),
        helperStyle: _bodySmallStyle.copyWith(color: textSecondary),
        errorStyle: _bodySmallStyle.copyWith(color: errorColor),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        indicatorColor: primaryColor.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => _labelMediumStyle.copyWith(
            color: states.contains(WidgetState.selected) ? primaryColor : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primaryColor : textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: _bodyMediumStyle.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _titleMediumStyle.copyWith(color: textPrimary),
        contentTextStyle: _bodyMediumStyle.copyWith(color: textSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: _displayLargeStyle,
      displayMedium: _displayMediumStyle,
      displaySmall: _displaySmallStyle,
      headlineLarge: _headlineLargeStyle,
      headlineMedium: _headlineMediumStyle,
      headlineSmall: _headlineSmallStyle,
      titleLarge: _titleLargeStyle,
      titleMedium: _titleMediumStyle,
      titleSmall: _titleSmallStyle,
      bodyLarge: _bodyLargeStyle,
      bodyMedium: _bodyMediumStyle,
      bodySmall: _bodySmallStyle,
      labelLarge: _labelLargeStyle,
      labelMedium: _labelMediumStyle,
      labelSmall: _labelSmallStyle,
    );
  }

  static const TextStyle _displayLargeStyle = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: textPrimary,
  );

  static const TextStyle _displayMediumStyle = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: textPrimary,
  );

  static const TextStyle _displaySmallStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: textPrimary,
  );

  static const TextStyle _headlineLargeStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: textPrimary,
  );

  static const TextStyle _headlineMediumStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: textPrimary,
  );

  static const TextStyle _headlineSmallStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: textPrimary,
  );

  static const TextStyle _titleLargeStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: textPrimary,
  );

  static const TextStyle _titleMediumStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.45,
    color: textPrimary,
  );

  static const TextStyle _titleSmallStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: textPrimary,
  );

  static const TextStyle _bodyLargeStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle _bodyMediumStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle _bodySmallStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.45,
    color: textSecondary,
  );

  static const TextStyle _labelLargeStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle _labelMediumStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.35,
    color: textPrimary,
  );

  static const TextStyle _labelSmallStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.35,
    color: textPrimary,
  );
}
