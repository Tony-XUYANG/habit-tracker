// ============================================================
// Achievement：成就系统
// 根据用户的打卡表现，解锁对应的成就徽章。
// 这是纯逻辑模型，不涉及界面，方便测试和维护。
// ============================================================

import 'habit.dart';

class Achievement {
  final String id; // 唯一标识
  final String title; // 成就名称
  final String description; // 达成条件的描述
  final String emoji; // 成就图标

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  // ------------------------------------------------------------
  // 预设的成就列表（全部可能解锁的成就）
  // ------------------------------------------------------------
  static const List<Achievement> all = [
    Achievement(
      id: 'first_habit',
      title: '启程',
      description: '创建第一个习惯',
      emoji: '🌱',
    ),
    Achievement(
      id: 'first_checkin',
      title: '第一次打卡',
      description: '完成第一次打卡',
      emoji: '✅',
    ),
    Achievement(
      id: 'streak_3',
      title: '小有坚持',
      description: '任意习惯连续打卡 3 天',
      emoji: '🔥',
    ),
    Achievement(
      id: 'streak_7',
      title: '一周不辍',
      description: '任意习惯连续打卡 7 天',
      emoji: '🏆',
    ),
    Achievement(
      id: 'streak_30',
      title: '月度达人',
      description: '任意习惯连续打卡 30 天',
      emoji: '👑',
    ),
    Achievement(
      id: 'total_50',
      title: '五十次达成',
      description: '累计打卡满 50 次',
      emoji: '💯',
    ),
    Achievement(
      id: 'total_100',
      title: '百炼成钢',
      description: '累计打卡满 100 次',
      emoji: '🌟',
    ),
    Achievement(
      id: 'habit_5',
      title: '习惯收藏家',
      description: '拥有 5 个习惯',
      emoji: '📚',
    ),
  ];

  // 按 id 查找成就
  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}

// ------------------------------------------------------------
// AchievementManager：成就判断逻辑
// 输入「所有习惯」，返回「已解锁的成就 id 集合」。
// ------------------------------------------------------------
class AchievementManager {
  // 计算当前已解锁的成就
  static Set<String> unlocked(List<Habit> habits) {
    final unlocked = <String>{};

    // 有任意习惯 → 解锁「启程」
    if (habits.isNotEmpty) unlocked.add('first_habit');

    // 拥有 5 个习惯 → 「习惯收藏家」
    if (habits.length >= 5) unlocked.add('habit_5');

    // 遍历所有习惯，汇总打卡表现
    int totalDone = 0; // 全部习惯累计打卡次数
    int maxStreak = 0; // 所有习惯中最长的连续打卡
    for (final h in habits) {
      totalDone += h.totalDone;
      if (h.streak > maxStreak) maxStreak = h.streak;
      if (h.bestStreak > maxStreak) maxStreak = h.bestStreak;
    }

    // 第一次打卡
    if (totalDone >= 1) unlocked.add('first_checkin');

    // 连续打卡成就（看最佳连续纪录，更稳定）
    if (maxStreak >= 3) unlocked.add('streak_3');
    if (maxStreak >= 7) unlocked.add('streak_7');
    if (maxStreak >= 30) unlocked.add('streak_30');

    // 累计次数成就
    if (totalDone >= 50) unlocked.add('total_50');
    if (totalDone >= 100) unlocked.add('total_100');

    return unlocked;
  }
}
