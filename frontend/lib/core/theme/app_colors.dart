import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDark1 = Color(0xFF070817);
  static const Color bgDark2 = Color(0xFF0D1024);
  static const Color bgDark3 = Color(0xFF151039);
  static const Color purple1 = Color(0xFF2B0B78);
  static const Color purple2 = Color(0xFF4F19D9);
  static const Color purple3 = Color(0xFF8738F5);

  static const Color cyan = Color(0xFF29E8FF);
  static const Color cyanDeep = Color(0xFF04A6C8);
  static const Color purpleAccent = Color(0xFF8A38F5);
  static const Color magenta = Color(0xFFC03CFF);

  static const Color glass = Color(0xFF131730);
  static const Color glassLight = Color(0xFF1A1E3F);
  static const Color border = Color(0x668A38F5);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFC8CADB);
  static const Color textMuted = Color(0xFF898DA8);

  static const Color success = Color(0xFF35E766);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4A61);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple3, purpleAccent, purple2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xB8141834), Color(0xA5100B2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color tint(Color color, double alpha) => color.withValues(alpha: alpha);
}
