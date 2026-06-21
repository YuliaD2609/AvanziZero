import 'package:flutter/material.dart';
import '../models/app_state.dart' show globalIsDarkMode;

class AppColors {
  // Colori Primari (Verde Salvia / Teal)
  static Color get primary =>
      globalIsDarkMode ? const Color(0xFF3D7A65) : const Color(0xFF5A9E87); // Più scuro in dark mode
  static Color get primaryDark =>
      globalIsDarkMode ? const Color(0xFF2E5C4C) : const Color(0xFF056C3F);
  static Color get primaryLight =>
      globalIsDarkMode ? const Color(0xFF1E3A30) : const Color(0xFFD1FAE5);

  // Colori Testo
  static Color get textPrimary =>
      globalIsDarkMode ? const Color(0xFFEAECE8) : const Color(0xFF1C3D32);
  static Color get textSecondary =>
      globalIsDarkMode ? const Color(0xFFA5B8B1) : const Color(0xFF789088);
  static Color get textHint =>
      globalIsDarkMode ? const Color(0xFF6E706A) : const Color(0xFFB8B6AF);

  // Colori Sfondo e Superficie
  static Color get background =>
      globalIsDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBF9);
  static Color get surfaceLight =>
      globalIsDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);

  // Colori Bordo
  static Color get border =>
      globalIsDarkMode ? const Color(0xFF333333) : const Color(0xFFEAECE8);
  static Color get borderLight =>
      globalIsDarkMode ? const Color(0xFF262626) : const Color(0xFFF2F3F0);

  // Colori di Stato (Feedback, Errori, Avvisi)
  static Color get error =>
      globalIsDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444);
  static Color get errorLight => globalIsDarkMode ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
  static Color get success => globalIsDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981);

  static Color get warning =>
      globalIsDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  static Color get warningLight =>
      globalIsDarkMode ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);

  // Ombre
  static Color get shadowLight => globalIsDarkMode ? const Color(0x33000000) : const Color(0x051C3D32);
  static Color get shadowMedium => globalIsDarkMode ? const Color(0x40000000) : const Color(0x081C3D32);
  static Color get shadowNavbar => globalIsDarkMode ? const Color(0x4D000000) : const Color(0x0A1C3D32);
  static Color get shadowDark => globalIsDarkMode ? const Color(0x80000000) : const Color(0x1A1C3D32);
}
