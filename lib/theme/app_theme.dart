import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bảng màu và phong cách thiết kế Warm Terracotta / Clay
/// Mô phỏng giao diện Dashboard hiện đại theo hình ảnh mẫu
class AppColors {
  // Gam màu chủ đạo (Terracotta / Coral clay)
  static const Color primary = Color(0xFFD46A4E);
  static const Color primaryLight = Color(0xFFF3DDD4);
  static const Color primaryDark = Color(0xFFA8462D);
  static const Color primaryGradientStart = Color(0xFFE27D60);
  static const Color primaryGradientEnd = Color(0xFFC3583C);

  // Gam màu nền ấm (Warm peach / Cream)
  static const Color background = Color(0xFFFAF1E8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFF5E7DA);
  static const Color sidebarBg = Color(0xFFD97251);

  // Màu phụ trợ (Trạng thái)
  static const Color sageGreen = Color(0xFF6B9080); // Còn hàng
  static const Color sageGreenLight = Color(0xFFE8F1EC);
  static const Color warmAmber = Color(0xFFE76F51); // Sắp hết
  static const Color warmAmberLight = Color(0xFFFDF0EB);
  static const Color softRed = Color(0xFFD64045); // Hết hàng
  static const Color softRedLight = Color(0xFFFBECEE);

  // Màu chữ (Typography)
  static const Color textPrimary = Color(0xFF2B211E);
  static const Color textSecondary = Color(0xFF8A7A74);
  static const Color textMuted = Color(0xFFB5A7A1);

  // Icon / Badge
  static const Color badgeYellow = Color(0xFFF4A261);
  static const Color badgeTeal = Color(0xFF70A9A1);
}

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.sidebarBg,
        surface: AppColors.cardBg,
        brightness: Brightness.light,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
