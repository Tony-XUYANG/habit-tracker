// ============================================================
// StatsHeader：页面顶部的统计卡片
// 显示「今日完成进度」+ 进度条 + 完成度百分比
// ============================================================

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme.dart';

class StatsHeader extends StatelessWidget {
  final List<Habit> habits; // 全部习惯，用来算今日完成度

  const StatsHeader({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final total = habits.length;
    // 今天已打卡的习惯数量
    final doneCount = habits.where((h) => h.isDoneToday).length;
    // 完成比例（0~1），总数为 0 时避免除以 0
    final ratio = total == 0 ? 0.0 : doneCount / total;
    final percent = (ratio * 100).round();

    return Card(
      color: AppTheme.primary, // 暖橙色卡片，作为视觉焦点
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今日完成',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  '$doneCount / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // 进度条：白色半透明底 + 白色实心进度
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
