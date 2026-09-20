// 基础的 Widget 冒烟测试：验证 App 能正常启动并渲染出「每日打卡」标题

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('App 启动并显示标题', (WidgetTester tester) async {
    // 构建 App 并触发一帧
    await tester.pumpWidget(const HabitTrackerApp());

    // 验证标题「每日打卡」已渲染
    expect(find.text('每日打卡'), findsOneWidget);

    // 验证右下角「添加」按钮存在
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
