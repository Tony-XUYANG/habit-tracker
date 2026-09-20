// ============================================================
// 每日打卡 · 习惯养成 App —— 程序入口 + 主界面
//
// 这是一个多文件结构的学习项目，阅读顺序：
//   1. lib/main.dart              —— 入口 + 主界面（本文件）
//   2. lib/models/habit.dart      —— 数据模型
//   3. lib/services/habit_store.dart —— 本地存储服务
//   4. lib/theme.dart             —— 主题颜色
//   5. lib/widgets/*.dart         —— 各 UI 组件
// ============================================================

import 'package:flutter/material.dart';

import 'models/habit.dart';
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
      theme: AppTheme.light, // 使用 theme.dart 里定义的主题
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
        // 首次使用：塞入示例习惯
        _habits = _seedHabits();
      } else {
        _habits = loaded;
      }
      _loading = false;
    });
    // 首次生成了示例数据，立即保存
    if (loaded.isEmpty) await _store.save(_habits);
  }

  // 生成示例习惯
  List<Habit> _seedHabits() {
    final now = DateTime.now();
    return [
      Habit(id: '1', name: '喝八杯水', emoji: '💧', createdAt: now),
      Habit(id: '2', name: '早睡早起', emoji: '🌙', createdAt: now),
      Habit(id: '3', name: '读书 30 分钟', emoji: '📖', createdAt: now),
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
    // 弹确认框，避免误删
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日打卡')),

      // 暖米色背景
      body: Container(
        color: AppTheme.background,
        child: _loading
            // 加载中：转圈
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                // 下拉刷新：重新从本地加载
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

  // 构建主体内容（空状态 或 列表）
  Widget _buildBody() {
    if (_habits.isEmpty) {
      // 空状态也能下拉刷新
      return ListView(
        children: const [
          SizedBox(height: 160),
          _EmptyState(),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 顶部统计卡片
        StatsHeader(habits: _habits),
        const SizedBox(height: 12),
        // 近 30 天热力图
        HabitHeatmap(habits: _habits),
        const SizedBox(height: 16),
        // 习惯列表
        ..._habits.map((habit) => HabitCard(
              habit: habit,
              onToggle: () => _toggleDone(habit),
              onDelete: () => _deleteHabit(habit),
            )),
      ],
    );
  }
}

// ------------------------------------------------------------
// _EmptyState：没有习惯时的提示
// ------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
