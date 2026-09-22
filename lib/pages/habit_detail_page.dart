// ============================================================
// HabitDetailPage：习惯详情页
// 点击习惯卡片进入，展示该习惯的完整数据：
//   - 本月打卡日历（月视图）
//   - 连续天数 / 累计次数 / 最佳纪录等统计
// ============================================================

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme.dart';

class HabitDetailPage extends StatelessWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cat = habit.category;

    return Scaffold(
      appBar: AppBar(
        title: Text('${habit.emoji} ${habit.name}'),
        // 分类色作为详情页顶栏色
        backgroundColor: cat.color,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppTheme.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 顶部统计卡片：连续/累计/最佳
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _statItem(label: '连续天数', value: '${habit.streak}'),
                    _divider(),
                    _statItem(label: '累计次数', value: '${habit.totalDone}'),
                    _divider(),
                    _statItem(label: '最佳纪录', value: '${habit.bestStreak}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 本月打卡日历
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${now.year} 年 ${now.month} 月 · 已打卡 ${habit.doneThisMonth} 天',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCalendar(now),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 元信息：创建日期、分类
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '习惯信息',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('分类', '${cat.emoji} ${cat.label}'),
                    const SizedBox(height: 8),
                    _infoRow(
                      '创建于',
                      '${habit.createdAt.year}-${habit.createdAt.month.toString().padLeft(2, '0')}-${habit.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 一行信息（标签 + 值）
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // 一个统计项（数值 + 标签）
  Widget _statItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // 垂直分隔线
  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
    );
  }

  // ------------------------------------------------------------
  // 构建本月日历：周一到周日排列，已打卡的日期用实心圆标记
  // ------------------------------------------------------------
  Widget _buildCalendar(DateTime now) {
    // 当月第一天
    final firstDay = DateTime(now.year, now.month, 1);
    // 当月总天数
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // 第一天是周几（周一=0 ... 周日=6），用于计算前面空几个格子
    final leadingBlanks = firstDay.weekday - 1;

    // 星期标题
    const weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

    return Column(
      children: [
        // 星期表头
        Row(
          children: weekLabels.map((w) {
            return Expanded(
              child: Center(
                child: Text(
                  w,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // 日期格子
        Wrap(
          children: [
            // 前置空白格
            ...List.generate(leadingBlanks, (_) => const _DayCell(day: 0, done: false, isToday: false)),
            // 实际日期格
            ...List.generate(daysInMonth, (i) {
              final day = i + 1;
              final date = DateTime(now.year, now.month, day);
              final done = habit.isDoneOn(date);
              final isToday = day == now.day;
              return _DayCell(day: day, done: done, isToday: isToday);
            }),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// _DayCell：日历中的单个日期格子
// ------------------------------------------------------------
class _DayCell extends StatelessWidget {
  final int day; // 日期（0 表示空白占位）
  final bool done; // 是否已打卡
  final bool isToday; // 是否今天

  const _DayCell({required this.day, required this.done, required this.isToday});

  @override
  Widget build(BuildContext context) {
    if (day == 0) {
      // 空白占位格
      return const SizedBox(width: 40, height: 40);
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // 已打卡：实心暖橙圆形；未打卡：透明
            color: done ? AppTheme.primary : Colors.transparent,
            shape: BoxShape.circle,
            // 今天：加一个边框高亮
            border: isToday && !done
                ? Border.all(color: AppTheme.primary, width: 1.5)
                : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              color: done ? Colors.white : Colors.grey.shade700,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
