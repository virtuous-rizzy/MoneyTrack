import 'package:flutter/material.dart';

/// Semua warna aplikasi ada di sini. Ubah di satu tempat, semua halaman ikut berubah.
class AppColors {
  static const bg = Color(0xFFF7F5EE);
  static const surface = Colors.white;
  static const primary = Color(0xFF1F2A44);
  static const accent = Color(0xFFB4C5DE);
  static const accentSoft = Color(0xFFDCE6F3);
  static const balanceCard = Color(0xFFD7E3F1);
  static const balanceCircle = Color(0xFFC6D6EA);
  static const beige = Color(0xFFDDD9CC);
  static const tagBg = Color(0xFFEFEDE4);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE8E4D8);
  static const income = Color(0xFF3A5A8C);
  static const danger = Color(0xFFC0504D);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.primary,
          displayColor: AppColors.primary,
        ),
  );
}
