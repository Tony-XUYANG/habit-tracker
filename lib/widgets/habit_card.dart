// ============================================================
// HabitCard：单个习惯的卡片
// 显示 emoji、名称、连续天数、累计天数、今日打卡按钮（带动画）
// ============================================================

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle; // 点击打卡按钮时触发
  final VoidCallback onDelete; // 点击删除时触发

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左：大 emoji 图标
            Text(habit.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),

            // 中：名称 + 连续/累计天数
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🔥 连续 ${habit.streak} 天 · 累计 ${habit.totalDone} 次',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 右：打卡按钮（带缩放动画）
            _CheckButton(done: done, onToggle: onToggle),

            // 删除按钮
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// _CheckButton：打卡按钮，打卡/取消时有缩放回弹动画
// ------------------------------------------------------------
class _CheckButton extends StatefulWidget {
  final bool done;
  final VoidCallback onToggle;

  const _CheckButton({required this.done, required this.onToggle});

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // 动画控制器
  late final Animation<double> _scale; // 缩放动画

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // 曲线：先放大再回弹，模拟「啪」一下的爽快感
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // 每次点击都从 0 开始播动画，产生缩放效果
    _controller.forward(from: 0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _handleTap,
      // ScaleTransition：让子组件跟随 _scale 动画缩放
      icon: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.done ? Icons.check_circle : Icons.circle_outlined,
          size: 32,
          color: widget.done ? AppTheme.success : Colors.grey.shade400,
        ),
      ),
    );
  }
}
