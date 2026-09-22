# 🌱 每日打卡 · 习惯养成 App

一个零基础友好的 Flutter 学习项目。用暖色治愈系界面，帮你记录每天的习惯打卡，统计坚持天数，可视化你的成长轨迹。

## 功能一览

- ✅ 添加 / 删除习惯（名称 + emoji 图标 + **分类标签**）
- ✅ **分类系统**：健康 / 学习 / 运动 / 生活 / 工作 / 其他，支持按分类筛选
- ✅ 每日一键打卡 / 取消打卡（带缩放回弹动画）
- ✅ **习惯详情页**：月历视图、连续天数、累计次数、最佳纪录
- ✅ **成就徽章系统**：8 种成就，持续打卡解锁
- ✅ 自动统计「连续打卡天数」+「最佳纪录」+ 累计总次数
- ✅ 今日完成度进度条 + 百分比
- ✅ 近 30 天打卡热力图（类似 GitHub 贡献图）
- ✅ 删除二次确认，防误删
- ✅ 下拉刷新
- ✅ 数据本地保存，重启 App 不丢失

## 技术要点（供学习）

| 知识点 | 位置 |
| --- | --- |
| 多文件项目分层（模型 / 服务 / 页面 / 组件） | `lib/models` `lib/services` `lib/pages` `lib/widgets` |
| `enum` 枚举（携带颜色、emoji 数据） | `models/habit_category.dart` |
| 页面导航 `Navigator.push` | `main.dart` 的 `_openDetail` / `_openAchievements` |
| 月历视图 + 日期运算 | `pages/habit_detail_page.dart` |
| 成就系统（纯逻辑模型 + 判断函数） | `models/achievement.dart` |
| 网格布局 `GridView` | `pages/achievement_page.dart` |
| 横向滚动筛选栏 `ListView` | `main.dart` 的 `_CategoryFilterBar` |
| `StatefulWidget` / `setState` 状态管理 | `main.dart`、`widgets/add_habit_dialog.dart` |
| 动画（`AnimationController` + `TweenSequence`） | `widgets/habit_card.dart` |
| 本地存储 `shared_preferences` | `services/habit_store.dart` |
| 进度条 / 热力图 / `Tooltip` | `widgets/stats_header.dart`、`habit_heatmap.dart` |

## 如何运行

前置条件：已安装 Flutter SDK（本项目开发环境为 Flutter 3.47.4 / Dart 3.13.3）。

```bash
# 1. 进入项目目录
cd habit_tracker

# 2. 拉取依赖（首次必须执行）
flutter pub get

# 3. 运行（自动选择可用设备：模拟器 / 真机 / Chrome / Windows 桌面）
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
├── main.dart                      # 程序入口 + 主界面 + 分类筛选
├── theme.dart                     # 主题颜色配置
├── models/
│   ├── habit.dart                 # 习惯数据模型
│   ├── habit_category.dart        # 分类枚举
│   └── achievement.dart           # 成就系统
├── services/
│   └── habit_store.dart           # 本地存储服务
├── pages/
│   ├── habit_detail_page.dart     # 习惯详情页（月历视图）
│   └── achievement_page.dart      # 成就徽章页
└── widgets/
    ├── habit_card.dart            # 习惯卡片（含打卡动画）
    ├── add_habit_dialog.dart      # 添加习惯弹窗
    ├── stats_header.dart          # 今日完成度统计卡片
    └── habit_heatmap.dart         # 近 30 天热力图
```

阅读顺序（每个文件顶部都有注释导航）：

1. `main.dart` — 入口，理解整体如何组装 + 导航
2. `models/habit.dart` → `habit_category.dart` → `achievement.dart` — 数据层
3. `services/habit_store.dart` — 数据如何持久化
4. `pages/` — 多页面如何导航
5. `widgets/` — 每个 UI 组件如何独立封装

## 学习建议

如果你是 Flutter 零基础，建议按这个顺序吃透本项目：

1. 先跑起来，玩一遍「添加（选分类）→ 打卡 → 进详情 → 看成就」
2. 读懂 `habit.dart`，理解数据模型与 `enum`
3. 读懂 `main.dart`，理解 `setState` + 页面导航
4. 读懂 `achievement.dart`，理解纯逻辑如何从界面解耦
5. 读懂 `habit_detail_page.dart` 的月历，理解日期运算
6. 尝试加新功能，比如「成就解锁动画」「每日提醒」「数据导出」

## License

MIT
