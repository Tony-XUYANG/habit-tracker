// ============================================================
// 每日打卡 · 习惯养成 App
// 一个零基础友好的 Flutter 学习项目
//
// 阅读顺序建议：
//   1. 先看 main()          —— 程序入口
//   2. 再看 HabitTrackerApp —— 应用外壳 + 主题（颜色/风格）
//   3. 再看 HomePage        —— 主界面 + 状态管理（setState）
//   4. 再看 Habit 数据模型   —— 一个「习惯」长什么样
//   5. 最后看其余小组件      —— 每个 UI 零件如何拼装
// ============================================================

// 导入 Flutter 的 Material 组件库（按钮、卡片、列表等都来自这里）
import 'package:flutter/material.dart';

// 导入本地存储插件：让打卡数据能存到手机里，重启后不丢
import 'package:shared_preferences/shared_preferences.dart';

// 导入 Dart 的 JSON 转换库：用来序列化/反序列化打卡数据
import 'dart:convert';

// ------------------------------------------------------------
// main()：程序入口。
// Flutter 启动时最先执行这里，然后 runApp 会撑起整个界面。
// ------------------------------------------------------------
void main() {
  // runApp 的作用：把一个 Widget「种」到屏幕上，成为整棵 UI 树的根
  runApp(const HabitTrackerApp());
}

// ------------------------------------------------------------
// HabitTrackerApp：整个应用的最外层。
// 它只做一件事：定义主题（Theme），也就是全 App 的颜色、字体风格。
// ------------------------------------------------------------
class HabitTrackerApp extends StatelessWidget {
  // const 构造函数：这个类不需要任何可变数据，所以用 const 让它更省内存
  const HabitTrackerApp({super.key});

  // build 是每个 Widget 的核心方法：描述「这个组件长什么样」
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 关闭右上角那个调试用的「DEBUG」水印，让界面更干净
      debugShowCheckedModeBanner: false,

      // App 标题（任务栏、切换应用时显示）
      title: '每日打卡',

      // 主题：暖色治愈风
      // Color(0xFF...) 表示颜色，FF 是不透明，后面 6 位是红绿蓝
      theme: ThemeData(
        // 种子色：Flutter 会根据它自动生成一系列和谐的颜色
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A87C), // 暖橙色（治愈感的主色调）
        ),
        // 使用 Material 3 设计语言（更现代、圆润）
        useMaterial3: true,

        // 卡片主题：让卡片有柔和的圆角和淡阴影
        cardTheme: CardThemeData(
          elevation: 1, // 阴影高度（数值越小越淡）
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 圆角 16
          ),
        ),
      ),

      // 首页：应用启动后看到的第一个界面
      home: const HomePage(),
    );
  }
}

// ------------------------------------------------------------
// Habit：数据模型，描述「一个习惯」包含哪些信息。
// 它只是一个普通的 Dart 类，不涉及界面。
// ------------------------------------------------------------
class Habit {
  final String id; // 唯一标识（用当前时间戳生成，防止重名冲突）
  final String name; // 习惯名称，比如「早睡」「喝水」
  final String emoji; // 该习惯的图标（用 emoji 表达，简单直观）
  final DateTime createdAt; // 创建时间
  final Set<String> doneDates; // 已完成打卡的日期集合（存 "2026-09-19" 这样的字符串）

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
    Set<String>? doneDates,
  }) : doneDates = doneDates ?? {}; // 如果没传，默认空集合

  // 计算「连续打卡天数」：从今天（或昨天）往回数，有多少天连续打了卡
  int get streak {
    // 拿到「今天」的日期字符串，格式统一成 yyyy-MM-dd
    var day = DateTime.now();
    // 如果今天还没打卡，就从昨天开始算（这样不会因为今天没打而立刻断档）
    if (!doneDates.contains(_format(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    int count = 0;
    // 只要「这一天」在打卡集合里，就继续往回数
    while (doneDates.contains(_format(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  // 判断「今天是否已打卡」
  bool get isDoneToday => doneDates.contains(_format(DateTime.now()));

  // 把 DateTime 格式化成 "yyyy-MM-dd" 字符串。
  // padLeft 的作用：月份/日期不足两位时补 0，比如 9 月 5 日 → "09-05"
  String _format(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // 把 Habit 转成 JSON（用于存入本地存储）
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'doneDates': doneDates.toList(),
      };

  // 从 JSON 数据还原出一个 Habit（用于从本地存储读取）
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

// ------------------------------------------------------------
// HomePage：主界面。
// 它是一个 StatefulWidget —— 因为里面有「会变化的数据」（习惯列表），
// 数据变了需要重绘界面，所以要用「有状态」的组件。
// ------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// _HomePageState：HomePage 的「状态」，真正持有数据、处理逻辑的地方
class _HomePageState extends State<HomePage> {
  // 习惯列表：存所有习惯
  List<Habit> _habits = [];

  // 本地存储的 key：数据就存在这个键名下
  static const _storageKey = 'habits';

  // initState：组件刚创建时自动调用一次，适合做「初始化」工作
  @override
  void initState() {
    super.initState();
    _loadHabits(); // 从本地读取之前保存的习惯
  }

  // 从本地存储加载习惯列表
  Future<void> _loadHabits() async {
    // 拿到本地存储对象（SharedPreferences 是异步的，所以用 await）
    final prefs = await SharedPreferences.getInstance();
    // 读取出 JSON 字符串（如果没有，返回空字符串）
    final raw = prefs.getString(_storageKey) ?? '';
    if (raw.isEmpty) {
      // 首次使用：没有数据，就塞几条「示例习惯」让界面不空
      setState(() {
        _habits = _seedHabits();
      });
      await _saveHabits();
      return;
    }
    // 把 JSON 字符串解析成 List，再逐个转成 Habit 对象
    final list = jsonDecode(raw) as List;
    setState(() {
      _habits = list.map((e) => Habit.fromJson(e)).toList();
    });
  }

  // 把当前习惯列表存到本地
  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    // 把所有 Habit 转成 JSON 列表，再整体序列化成字符串存起来
    final list = _habits.map((h) => h.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  // 生成几条示例习惯（第一次打开 App 时展示）
  List<Habit> _seedHabits() {
    final now = DateTime.now();
    return [
      Habit(id: '1', name: '喝八杯水', emoji: '💧', createdAt: now),
      Habit(id: '2', name: '早睡早起', emoji: '🌙', createdAt: now),
      Habit(id: '3', name: '读书 30 分钟', emoji: '📖', createdAt: now),
    ];
  }

  // 添加一个习惯（弹窗输入名称和 emoji）
  Future<void> _addHabit() async {
    // showDialog 弹出一个对话框，返回值是用户输入的结果
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddHabitDialog(),
    );
    if (result == null) return; // 用户取消了
    setState(() {
      _habits.add(Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 用时间戳当 id
        name: result['name']!,
        emoji: result['emoji'] ?? '⭐',
        createdAt: DateTime.now(),
      ));
    });
    await _saveHabits();
  }

  // 切换某习惯「今天」的打卡状态（打了 → 取消，没打 → 打上）
  Future<void> _toggleDone(Habit habit) async {
    final today = _format(DateTime.now());
    setState(() {
      if (habit.doneDates.contains(today)) {
        habit.doneDates.remove(today); // 取消打卡
      } else {
        habit.doneDates.add(today); // 打卡
      }
    });
    await _saveHabits();
  }

  // 删除一个习惯
  Future<void> _deleteHabit(Habit habit) async {
    setState(() {
      _habits.remove(habit);
    });
    await _saveHabits();
  }

  // 日期格式化工具（和数据模型里的一致）
  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // build：描述主界面长什么样
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 顶栏背景设为暖橙色，文字白色
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8A87C),
        foregroundColor: Colors.white,
        title: const Text('每日打卡'),
        centerTitle: true,
      ),
      // 页面主体：暖米色背景，营造治愈感
      body: Container(
        color: const Color(0xFFFDF6EF),
        child: _habits.isEmpty
            // 如果没有任何习惯，显示一个「空状态」提示
            ? const _EmptyState()
            // 否则显示习惯列表
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _habits.length,
                itemBuilder: (context, index) {
                  final habit = _habits[index];
                  return _HabitCard(
                    habit: habit,
                    onToggle: () => _toggleDone(habit),
                    onDelete: () => _deleteHabit(habit),
                  );
                },
              ),
      ),
      // 右下角悬浮按钮：点击添加新习惯
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8A87C),
        foregroundColor: Colors.white,
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ------------------------------------------------------------
// _HabitCard：单个习惯的卡片。
// 显示 emoji、名称、连续天数、今日打卡按钮。
// ------------------------------------------------------------
class _HabitCard extends StatelessWidget {
  final Habit habit; // 这个卡片展示的习惯
  final VoidCallback onToggle; // 点击打卡按钮时触发
  final VoidCallback onDelete; // 点击删除时触发

  const _HabitCard({
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday; // 今天是否已打卡

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左边：大 emoji 图标
            Text(habit.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            // 中间：名称 + 连续天数（可伸展，占据剩余空间）
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
                  // 连续打卡徽章：🔥 表示坚持了多少天
                  Text(
                    '🔥 连续 ${habit.streak} 天',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // 右边：打卡按钮（今天已完成就变成实心对勾，未完成是空心圆）
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                size: 32,
                color: done ? const Color(0xFF6BBE9C) : Colors.grey.shade400,
              ),
            ),
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
// _AddHabitDialog：添加习惯的弹窗。
// 用户输入「名称」，从预设的 emoji 里挑一个图标。
// ------------------------------------------------------------
class _AddHabitDialog extends StatefulWidget {
  const _AddHabitDialog();

  @override
  State<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<_AddHabitDialog> {
  // 输入框的控制器：用来读取用户输入的文本
  final _controller = TextEditingController();

  // 当前选中的 emoji（默认星星）
  String _selectedEmoji = '⭐';

  // 供选择的 emoji 列表
  static const _emojiOptions = ['💧', '🌙', '📖', '🏃', '🧘', '🎨', '💪', '🍎'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新习惯'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // 让弹窗高度自适应内容
        children: [
          // 文本输入框
          TextField(
            controller: _controller,
            autofocus: true, // 自动弹出键盘
            decoration: const InputDecoration(
              hintText: '习惯名称，例如：早起',
            ),
          ),
          const SizedBox(height: 16),
          // emoji 选择区：一排可点选的图标
          Wrap(
            spacing: 12,
            children: _emojiOptions.map((e) {
              final selected = e == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE8A87C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        // 取消按钮：关闭弹窗，返回 null
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        // 确定按钮：把输入结果返回给调用方
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return; // 名称为空不处理
            Navigator.pop(context, {'name': name, 'emoji': _selectedEmoji});
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// _EmptyState：没有习惯时的空状态提示。
// ------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            '还没有习惯，点右下角 + 添加一个吧',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
