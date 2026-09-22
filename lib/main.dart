// ============================================================
// 每日打卡 · 习惯养成 App —— 程序入口 + 主界面
//
// 多文件结构学习项目，阅读顺序：
//   1. lib/main.dart                  —— 入口 + 主界面（本文件）
//   2. lib/models/habit.dart          —— 数据模型
//   3. lib/models/habit_category.dart —— 分类枚举
//   4. lib/models/achievement.dart    —— 成就系统
//   5. lib/services/habit_store.dart  —— 本地存储服务
//   6. lib/theme.dart                 —— 主题颜色
//   7. lib/pages/*.dart               —— 详情页 / 成就页
//   8. lib/widgets/*.dart             —— 各 UI 组件
// ============================================================

import 'package:flutter/material.dart';

import 'models/habit.dart';
import 'models/habit_category.dart';
import 'pages/achievement_page.dart';
import 'pages/habit_detail_page.dart';
import 'services/habit_store.dart';
import 'theme.dart';
import 'widgets/add_habit_dialog.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_heatmap.dart';
import 'widgets/stats_header.dart';

// ------------------------------------------------------------
// main()：程序入口
// ------------------------------------------------------------
void main() {
  runApp(const HabitTrackerApp());
}

// ------------------------------------------------------------
// HabitTrackerApp：应用外壳，定义主题
// ------------------------------------------------------------
class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '每日打卡',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

// ------------------------------------------------------------
// HomePage：主界面（有状态，管理习惯列表）
// ------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Habit> _habits = []; // 习惯列表
  final _store = HabitStore(); // 存储服务
  bool _loading = true; // 是否正在加载数据

  // 分类筛选：null 表示「全部」，否则只显示该分类
  HabitCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // 加载数据（含首次启动时生成示例数据）
  Future<void> _loadHabits() async {
    final loaded = await _store.load();
    setState(() {
      if (loaded.isEmpty) {
        _habits = _seedHabits();
      } else {
        _habits = loaded;
      }
      _loading = false;
    });
    if (loaded.isEmpty) await _store.save(_habits);
  }

  // 生成示例习惯（含不同分类，方便展示筛选功能）
  List<Habit> _seedHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: '1',
        name: '喝八杯水',
        emoji: '💧',
        category: HabitCategory.health,
        createdAt: now,
      ),
      Habit(
        id: '2',
        name: '早睡早起',
        emoji: '🌙',
        category: HabitCategory.life,
        createdAt: now,
      ),
      Habit(
        id: '3',
        name: '读书 30 分钟',
        emoji: '📖',
        category: HabitCategory.study,
        createdAt: now,
      ),
      Habit(
        id: '4',
        name: '晨跑 3 公里',
        emoji: '🏃',
        category: HabitCategory.sport,
        createdAt: now,
      ),
    ];
  }

  // 添加习惯
  Future<void> _addHabit() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddHabitDialog(),
    );
    if (result == null) return;
    setState(() {
      _habits.add(Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name']!,
        emoji: result['emoji'] ?? '⭐',
        category: HabitCategory.fromName(result['category']),
        createdAt: DateTime.now(),
      ));
    });
    await _store.save(_habits);
  }

  // 切换打卡状态
  Future<void> _toggleDone(Habit habit) async {
    final today = Habit.today;
    setState(() {
      if (habit.doneDates.contains(today)) {
        habit.doneDates.remove(today);
      } else {
        habit.doneDates.add(today);
      }
    });
    await _store.save(_habits);
  }

  // 删除习惯（带二次确认）
  Future<void> _deleteHabit(Habit habit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除习惯'),
        content: Text('确定要删除「${habit.name}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _habits.remove(habit));
    await _store.save(_habits);
  }

  // 进入习惯详情页
  void _openDetail(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailPage(habit: habit),
      ),
    );
  }

  // 进入成就页
  void _openAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementPage(habits: _habits),
      ),
    );
  }

  // 根据当前筛选分类，得到要显示的习惯列表
  List<Habit> get _filteredHabits {
    if (_filterCategory == null) return _habits;
    return _habits.where((h) => h.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每日打卡'),
        actions: [
          // 右上角成就入口
          IconButton(
            onPressed: _openAchievements,
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: '成就',
          ),
        ],
      ),

      body: Container(
        color: AppTheme.background,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHabits,
                child: _buildBody(),
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建主体内容（分类筛选栏 + 统计 + 列表）
  Widget _buildBody() {
    final filtered = _filteredHabits;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 顶部统计卡片（始终显示全部习惯的统计）
        StatsHeader(habits: _habits),
        const SizedBox(height: 12),
        // 近 30 天热力图
        HabitHeatmap(habits: _habits),
        const SizedBox(height: 16),
        // 分类筛选栏
        _CategoryFilterBar(
          selected: _filterCategory,
          onSelect: (c) => setState(() => _filterCategory = c),
        ),
        const SizedBox(height: 8),
        // 习惯列表（受筛选影响）
        if (filtered.isEmpty)
          const _NoResult()
        else
          ...filtered.map((habit) => HabitCard(
                habit: habit,
                onToggle: () => _toggleDone(habit),
                onDelete: () => _deleteHabit(habit),
                onTap: () => _openDetail(habit),
              )),
      ],
    );
  }
}

// ------------------------------------------------------------
// _CategoryFilterBar：分类筛选栏（横向滚动的标签）
// 「全部」+ 各分类，点击切换筛选
// ------------------------------------------------------------
class _CategoryFilterBar extends StatelessWidget {
  final HabitCategory? selected;
  final ValueChanged<HabitCategory?> onSelect;

  const _CategoryFilterBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // 把「全部」和所有分类拼成一个列表
    final items = <HabitCategory?>[null, ...HabitCategory.values];

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items.map((c) {
          final isSelected = c == selected;
          // 「全部」没有颜色，用主题色
          final color = c?.color ?? AppTheme.primary;
          final label = c == null ? '全部' : '${c.emoji} ${c.label}';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ------------------------------------------------------------
// _NoResult：筛选后无结果时的提示
// ------------------------------------------------------------
class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              '这个分类下还没有习惯',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

