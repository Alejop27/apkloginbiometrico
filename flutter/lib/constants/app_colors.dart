/// app_colors.dart
///
/// Define la paleta de colores pastel y el tema global de la aplicación.
/// Centralizar los colores aquí evita "magic colors" dispersos en la UI.

import 'package:flutter/material.dart';

/// Paleta de colores pastel de la aplicación.
abstract class AppColors {
  // ── Fondos ──────────────────────────────────────────────────────────────────
  /// Fondo principal: blanco hueso / crema suave
  static const Color background = Color(0xFFFDFBF7);

  /// Fondo de tarjetas: blanco puro con sombra tenue
  static const Color card = Color(0xFFFFFFFF);

  // ── Acentos ─────────────────────────────────────────────────────────────────
  /// Azul cielo suave — botones primarios, encabezados
  static const Color accentBlue = Color(0xFFAEC6CF);

  /// Verde menta — badges de descuento, confirmaciones
  static const Color accentGreen = Color(0xFFB1D8B7);

  /// Rosa palo — acentos secundarios, chips
  static const Color accentPink = Color(0xFFFFD1DC);

  // ── Texto ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF3A3A3A);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Precios ─────────────────────────────────────────────────────────────────
  /// Color del precio con descuento aplicado
  static const Color priceDiscount = Color(0xFF5A9A6F);

  /// Color del precio original tachado
  static const Color priceOriginal = Color(0xFFB0B0B0);

  // ── Valoración ───────────────────────────────────────────────────────────────
  /// Amarillo/dorado pastel para las estrellas de valoración
  static const Color starFilled = Color(0xFFFFD580);
  static const Color starEmpty = Color(0xFFDEDEDE);

  // ── Divisores / bordes ───────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEFEFEF);
  static const Color border = Color(0xFFE8E8E8);
}

/// Tema global de la aplicación — tipografía, formas y colores de Material.
abstract class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          background: AppColors.background,
          surface: AppColors.card,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  /// Sombra estándar para tarjetas — tenue y elegante.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
