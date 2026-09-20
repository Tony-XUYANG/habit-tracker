// ============================================================
// 主题配置：集中管理全 App 的颜色、风格
// 把颜色常量放在这里，改主题时只需要改这一个文件。
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // 暖橙色 —— 治愈感的主色调（顶栏、按钮、种子色）
  static const Color primary = Color(0xFFE8A87C);

  // 暖米色 —— 页面背景，柔和护眼
  static const Color background = Color(0xFFFDF6EF);

  // 打卡成功的绿色
  static const Color success = Color(0xFF6BBE9C);

  // 构建整个 App 的主题数据
  static ThemeData get light {
    return ThemeData(
      // 种子色：Flutter 会据此自动生成一套和谐的颜色
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,

      // 卡片：柔和圆角 + 淡阴影
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 悬浮按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      // 顶部栏主题
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    );
  }
}
