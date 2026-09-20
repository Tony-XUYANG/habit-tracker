// ============================================================
// HabitHeatmap：近 30 天打卡热力图
// 用一排排小方块表示每天的打卡情况，颜色越深代表打卡越多。
// 类似 GitHub 的贡献热力图，是很好的可视化组件。
// ============================================================

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme.dart';

class HabitHeatmap extends StatelessWidget {
  final List<Habit> habits;
  final int days; // 展示最近多少天（默认 30）

  const HabitHeatmap({super.key, required this.habits, this.days = 30});

  @override
  Widget build(BuildContext context) {
    // 今天
    final now = DateTime.now();
    // 生成最近 days 天的日期列表（从最旧到今天）
    final dateList = List.generate(
      days,
      (i) => now.subtract(Duration(days: days - 1 - i)),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              '近 30 天打卡',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // 热力图网格：每行 7 个（一周）
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: dateList.map((date) {
                // 这一天有多少个习惯打了卡
                final count = habits.where((h) => h.isDoneOn(date)).length;
                // 根据打卡数量决定颜色深浅（0 为最浅）
                final color = _heatColor(count, habits.isEmpty ? 1 : habits.length);
                return Tooltip(
                  // 鼠标悬停/长按显示详情
                  message: '${Habit.formatDate(date)} · $count 次打卡',
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // 图例：浅 → 深
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('少', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 4),
                ...List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _heatColor(i, 3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Text('多', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 根据打卡次数返回颜色。
  // ratio = 当天打卡数 / 习惯总数，比例越高颜色越深。
  // ------------------------------------------------------------
  Color _heatColor(int count, int total) {
    final ratio = total == 0 ? 0.0 : count / total;
    if (count == 0) return Colors.grey.shade200; // 没打卡：浅灰
    if (ratio < 0.34) return AppTheme.primary.withValues(alpha: 0.35);
    if (ratio < 0.67) return AppTheme.primary.withValues(alpha: 0.65);
    return AppTheme.primary; // 全打：最深的暖橙
  }
}
