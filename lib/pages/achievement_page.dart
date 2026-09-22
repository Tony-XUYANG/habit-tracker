// ============================================================
// AchievementPage：成就页面
// 展示所有成就徽章，已解锁的亮色显示，未解锁的置灰。
// ============================================================

import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/habit.dart';
import '../theme.dart';

class AchievementPage extends StatelessWidget {
  final List<Habit> habits;

  const AchievementPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // 计算当前已解锁的成就 id 集合
    final unlocked = AchievementManager.unlocked(habits);
    final all = Achievement.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就徽章'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppTheme.background,
        child: Column(
          children: [
            // 顶部进度：已解锁 X / 总数
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '已解锁',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${unlocked.length} / ${all.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // 成就网格
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 每行 2 个
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4, // 宽高比
                ),
                itemCount: all.length,
                itemBuilder: (context, index) {
                  final a = all[index];
                  final isUnlocked = unlocked.contains(a.id);
                  return _AchievementCard(
                    achievement: a,
                    unlocked: isUnlocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// _AchievementCard：单个成就卡片
// ------------------------------------------------------------
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // 未解锁：半透明，降低存在感
      color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 成就图标：未解锁用灰色滤镜
            Opacity(
              opacity: unlocked ? 1.0 : 0.3,
              child: Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: unlocked ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: unlocked ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
