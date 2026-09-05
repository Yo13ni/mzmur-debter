import 'package:flutter/material.dart';

/// Dark teal palette matching the Orthodox mezmur player UI.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0C3E47);
  static const Color bgDeep = Color(0xFF06252B);
  static const Color nav = Color(0xFF061E24);
  static const Color card = Color(0xFF1A5B6B);
  static const Color cardLight = Color(0xFF216A7C);
  static const Color player = Color(0xFF163238);
  static const Color playButton = Color(0xFF5C7784);
  static const Color searchBar = Color(0xFFD6D6D6);
  static const Color searchHint = Color(0xFF5A5A5A);

  static const Color primary = Color(0xFF1A5B6B);
  static const Color primaryDark = Color(0xFF0C3E47);
  static const Color accent = Color(0xFFA0BCC2);

  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFFB8C9CE);
  static const Color danger = Color(0xFFE57373);
  static const Color gold = Color(0xFFE8C547);

  // Keep aliases so older screens compile during migration
  static const Color cream = bg;
  static const Color creamDark = bgDeep;
  static const Color paper = bg;
  static const Color primarySoft = card;
  static const Color primaryMuted = cardLight;
  static const Color border = Color(0xFF2A5A66);
  static const Color divider = Color(0xFF3A6A76);
  static const Color darkBg = bg;
  static const Color darkCard = card;
  static const Color darkInk = ink;
  static const Color darkMuted = inkMuted;
  static const Color darkBorder = border;
}
