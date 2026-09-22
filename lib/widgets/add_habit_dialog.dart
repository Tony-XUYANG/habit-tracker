// ============================================================
// AddHabitDialog：添加习惯的弹窗
// 用户输入「名称」、挑「emoji 图标」、选「分类」
// ============================================================

import 'package:flutter/material.dart';
import '../models/habit_category.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _controller = TextEditingController(); // 读取输入文本
  String _selectedEmoji = '⭐'; // 当前选中的 emoji
  HabitCategory _selectedCategory = HabitCategory.other; // 当前选中的分类

  // 供选择的 emoji 列表
  static const _emojiOptions = ['💧', '🌙', '📖', '🏃', '🧘', '🎨', '💪', '🍎'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新习惯'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称输入框
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '习惯名称，例如：早起'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            // 分类选择
            const Text('分类', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HabitCategory.values.map((c) {
                final selected = c == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? c.color : c.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? c.color : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '${c.emoji} ${c.label}',
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white : c.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // emoji 图标选择
            const Text('图标', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _emojiOptions.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE8A87C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('确定'),
        ),
      ],
    );
  }

  // 确定：把输入结果返回给调用方
  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, {
      'name': name,
      'emoji': _selectedEmoji,
      'category': _selectedCategory.name,
    });
  }
}
