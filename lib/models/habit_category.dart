// ============================================================
// HabitCategory：习惯分类枚举
// 给习惯打上分类标签，支持按分类筛选。
//
// enum 是 Dart 里表示「一组固定选项」的类型，
// 每个选项可以携带额外的数据（这里带了显示名和 emoji）。
// ============================================================

import 'package:flutter/material.dart';

enum HabitCategory {
  health('健康', '💪', Color(0xFF6BBE9C)),
  study('学习', '📚', Color(0xFF6B9CE8)),
  sport('运动', '🏃', Color(0xFFE88A6B)),
  life('生活', '🌿', Color(0xFFB08BE8)),
  work('工作', '💼', Color(0xFFE8B86B)),
  other('其他', '⭐', Color(0xFF9A9A9A));

  // 枚举的字段：中文名、图标、主题色
  final String label;
  final String emoji;
  final Color color;

  // 枚举构造函数必须是 const
  const HabitCategory(this.label, this.emoji, this.color);

  // 从字符串还原分类（读取本地数据时用），找不到就归为「其他」
  static HabitCategory fromName(String? name) {
    return HabitCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => HabitCategory.other,
    );
  }
}
