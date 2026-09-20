// ============================================================
// AddHabitDialog：添加习惯的弹窗
// 用户输入「名称」，从预设 emoji 里挑一个图标
// ============================================================

import 'package:flutter/material.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _controller = TextEditingController(); // 读取输入文本
  String _selectedEmoji = '⭐'; // 当前选中的 emoji

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '习惯名称，例如：早起'),
            // 回车直接确定
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
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
    if (name.isEmpty) return; // 空名称不处理
    Navigator.pop(context, {'name': name, 'emoji': _selectedEmoji});
  }
}
