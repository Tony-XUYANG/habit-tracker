# 🌱 每日打卡 · 习惯养成 App

一个零基础友好的 Flutter 学习项目。用暖色治愈系界面，帮你记录每天的习惯打卡，统计连续坚持天数。

## 功能一览

- ✅ 添加 / 删除习惯（名称 + 自定义 emoji 图标）
- ✅ 每日一键打卡 / 取消打卡
- ✅ 自动统计「连续打卡天数」（🔥 火苗徽章）
- ✅ 数据本地保存，重启 App 不丢失
- ✅ 首次打开自带 3 条示例习惯

## 技术要点（供学习）

| 知识点 | 位置 |
| --- | --- |
| `StatefulWidget` / `setState` 状态管理 | `HomePage`、`_AddHabitDialog` |
| `StatelessWidget` 无状态组件 | `HabitTrackerApp`、`_HabitCard`、`_EmptyState` |
| 数据模型 + JSON 序列化 | `Habit` 类 |
| 本地存储 `shared_preferences` | `_loadHabits` / `_saveHabits` |
| 对话框 `showDialog` | `_addHabit` |
| 列表渲染 `ListView.builder` | `HomePage` |
| Dart 日期运算 | `Habit.streak` |

## 如何运行

前置条件：已安装 Flutter SDK（本项目开发环境为 Flutter 3.47.4 / Dart 3.13.3）。

```bash
# 1. 进入项目目录
cd habit_tracker

# 2. 拉取依赖（首次必须执行）
flutter pub get

# 3. 运行（会自动选择可用设备：模拟器 / 真机 / Chrome / Windows 桌面）
flutter run
```

> 国内网络建议先配置镜像加速：
> ```bash
> # Windows (PowerShell)
> $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
> $env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
> ```

## 代码结构

```
lib/
└── main.dart   # 全部代码都在这一个文件里，便于初学者从头读到尾
```

`main.dart` 内部阅读顺序（文件顶部有注释导航）：

1. `main()` — 程序入口
2. `HabitTrackerApp` — 应用外壳 + 暖色主题
3. `Habit` — 数据模型（一个「习惯」长什么样）
4. `HomePage` — 主界面 + 状态管理
5. `_HabitCard` / `_AddHabitDialog` / `_EmptyState` — 各 UI 零件

## 学习建议

如果你是 Flutter 零基础，建议按这个顺序吃透本项目：

1. 先跑起来，玩一遍「添加 → 打卡 → 删除」
2. 读懂 `Habit` 类，理解数据模型
3. 读懂 `HomePage`，理解 `setState` 如何驱动界面刷新
4. 改动一个颜色、一个 emoji，观察变化，建立手感
5. 尝试加一个新功能，比如「打卡弹提示」或「长按删除」

## License

MIT
