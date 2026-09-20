// ============================================================
// Habit 数据模型
// 描述「一个习惯」包含哪些信息，以及和习惯相关的计算逻辑。
// 这是一个纯 Dart 类，不涉及任何界面代码。
// ============================================================

class Habit {
  final String id; // 唯一标识（用时间戳生成，防止重名冲突）
  final String name; // 习惯名称，比如「早睡」「喝水」
  final String emoji; // 该习惯的图标（用 emoji 表达，简单直观）
  final DateTime createdAt; // 创建时间
  final Set<String> doneDates; // 已完成打卡的日期集合（存 "2026-09-20" 这样的字符串）

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
    Set<String>? doneDates,
  }) : doneDates = doneDates ?? {};

  // ------------------------------------------------------------
  // 把 DateTime 格式化成 "yyyy-MM-dd" 字符串。
  // padLeft：不足两位补 0，比如 9 月 5 日 → "09-05"
  // 用 static 是因为它不依赖具体某个 Habit 实例，全局通用。
  // ------------------------------------------------------------
  static String formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // 今天的日期字符串
  static String get today => formatDate(DateTime.now());

  // 判断「今天是否已打卡」
  bool get isDoneToday => doneDates.contains(today);

  // 判断「指定某一天是否已打卡」（热力图用）
  bool isDoneOn(DateTime d) => doneDates.contains(formatDate(d));

  // ------------------------------------------------------------
  // 连续打卡天数：从今天（或昨天）往回数，连续打了几天的卡
  // ------------------------------------------------------------
  int get streak {
    var day = DateTime.now();
    // 今天还没打，就从昨天开始数，避免今天没打立刻归零
    if (!doneDates.contains(formatDate(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    int count = 0;
    while (doneDates.contains(formatDate(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  // ------------------------------------------------------------
  // 累计打卡总天数（历史所有打过卡的天数）
  // ------------------------------------------------------------
  int get totalDone => doneDates.length;

  // ------------------------------------------------------------
  // JSON 序列化：把 Habit 转成 Map，用于存入本地存储
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'doneDates': doneDates.toList(),
      };

  // ------------------------------------------------------------
  // JSON 反序列化：从 Map 还原出 Habit 对象
  // ------------------------------------------------------------
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      doneDates: (json['doneDates'] as List).map((e) => e.toString()).toSet(),
    );
  }
}
