// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color accent  = Color(0xFF3B82F6);

  // ── Palette dark ─────────────────────────────────────
  static const Color _darkBg      = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkText    = Color(0xFFF1F5F9);
  static const Color _darkMuted   = Color(0xFF94A3B8);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ColorScheme = source unique de vérité, pas de textTheme explicite
    colorScheme: const ColorScheme.dark(
      primary:             accent,
      onPrimary:           Colors.white,
      secondary:           accent,
      onSecondary:         Colors.white,
      surface:             _darkSurface,
      onSurface:           _darkText,
      surfaceContainerHighest: _darkSurface,
      onSurfaceVariant:    _darkMuted,
      outline:             Color(0xFF334155),
      outlineVariant:      Color(0xFF1E293B),
      error:               Color(0xFFEF4444),
      onError:             Colors.white,
    ),

    scaffoldBackgroundColor: _darkBg,

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkText,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: _darkText),
      actionsIconTheme: IconThemeData(color: _darkText),
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkText,
        side: const BorderSide(color: Color(0xFF475569)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      filled: true,
      fillColor: _darkSurface,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor:   accent,
      unselectedItemColor: _darkMuted,
      type: BottomNavigationBarType.fixed,
    ),

    iconTheme:        const IconThemeData(color: _darkMuted),
    primaryIconTheme: const IconThemeData(color: _darkText),

    listTileTheme: const ListTileThemeData(
      tileColor:  Colors.transparent,
      iconColor:  _darkMuted,
      textColor:  _darkText,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? accent : const Color(0xFF475569)),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? accent.withValues(alpha: 0.4)
              : const Color(0xFF334155)),
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: _darkSurface,
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: _darkSurface,
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(_darkSurface),
      ),
    ),

    dividerColor: const Color(0xFF334155),
    dividerTheme: const DividerThemeData(color: Color(0xFF334155)),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF334155),
      labelStyle: TextStyle(color: _darkText),
      iconTheme: IconThemeData(color: _darkMuted),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF334155),
      contentTextStyle: TextStyle(color: _darkText),
      actionTextColor: accent,
    ),
  );
}