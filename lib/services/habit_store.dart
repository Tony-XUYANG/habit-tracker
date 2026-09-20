// ============================================================
// HabitStore：数据存储服务
// 负责「读写本地存储」——把习惯列表存到手机里、读出来。
// 把存储逻辑从界面里抽离出来，界面只管调用，不关心数据怎么存的。
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitStore {
  // 本地存储用的 key，数据就存在这个键名下
  static const _storageKey = 'habits';

  // ------------------------------------------------------------
  // 加载习惯列表：如果没有数据，返回空列表
  // ------------------------------------------------------------
  Future<List<Habit>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey) ?? '';
    if (raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Habit.fromJson(e)).toList();
  }

  // ------------------------------------------------------------
  // 保存习惯列表：把整个列表序列化后写入本地
  // ------------------------------------------------------------
  Future<void> save(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final list = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }
}
