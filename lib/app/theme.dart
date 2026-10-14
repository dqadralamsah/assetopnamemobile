import 'package:flutter/material.dart';

import '../shared/models/opname_result.dart';

/// Warna sesuai mockup Full Design.
class AppColors {
  AppColors._();

  static const forest = Color(0xFF0E3B2E); // hijau tua (header, tombol)
  static const forestLight = Color(0xFF1B5A44);
  static const lime = Color(0xFFC8F169); // aksen
  static const limeSoft = Color(0xFFE4F7BE);
  static const buttonText = Color(0xFFDDF7A0);
  static const bg = Color(0xFFF2F1EC);
  static const card = Colors.white;
  static const ink = Color(0xFF14211B);
  static const muted = Color(0xFF6B756F);
  static const line = Color(0xFFE2E3DD);
  static const ok = Color(0xFF1E8A5A);
  static const okSoft = Color(0xFFE1F3E9);
  static const warn = Color(0xFFDB8616);
  static const warnSoft = Color(0xFFFFF1DC);
  static const danger = Color(0xFFC8372F);
  static const dangerSoft = Color(0xFFFBE4E2);
  static const info = Color(0xFF3A67C9);
  static const infoSoft = Color(0xFFE5ECFA);
  static const pending = Color(0xFF8A928D);
}

Color statusColor(OpnameStatus? status) => switch (status) {
      null => AppColors.pending,
      OpnameStatus.sesuai => AppColors.ok,
      OpnameStatus.kondisiBerubah => AppColors.warn,
      OpnameStatus.bedaLokasi => AppColors.warn,
      OpnameStatus.tidakDitemukan => AppColors.danger,
    };

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      primary: AppColors.forest,
      surface: Colors.white,
    );
    final radius12 = BorderRadius.circular(12);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // Tombol besar supaya mudah ditekan di lapangan (pakai sarung tangan).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.buttonText,
          disabledBackgroundColor: AppColors.line,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.ink, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.forest, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.forest,
      ),
    );
  }
}
