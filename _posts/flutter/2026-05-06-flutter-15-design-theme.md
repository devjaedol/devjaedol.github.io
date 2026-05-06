---
title: "[Flutter] 15. 디자인 - 테마, 스타일, 반응형"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

앱의 전체 디자인을 통일하는 테마 설정과 반응형 레이아웃을 배웁니다.

# ThemeData (앱 전체 테마)

## 테마 설정

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        // 색상 스킴
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        // AppBar 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // 텍스트 테마
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),

        // 입력 필드 테마
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
```

## 다크 모드 지원

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: ThemeMode.system, // system / light / dark
  home: const HomePage(),
)
```

## 테마 값 사용

```dart
@override
Widget build(BuildContext context) {
  // 현재 테마 가져오기
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Column(
    children: [
      Text(
        '제목',
        style: theme.textTheme.headlineLarge,
      ),
      Container(
        color: colorScheme.primaryContainer,
        child: Text(
          '본문',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    ],
  );
}
```

---

# 텍스트 스타일

```dart
Text(
  '스타일 적용 텍스트',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,    // 굵기
    color: Colors.blue,
    letterSpacing: 1.5,             // 자간
    height: 1.5,                    // 줄 간격
    decoration: TextDecoration.underline, // 밑줄
    fontStyle: FontStyle.italic,    // 기울임
  ),
  textAlign: TextAlign.center,      // 정렬
  maxLines: 2,                      // 최대 줄 수
  overflow: TextOverflow.ellipsis,  // 넘침 처리 (...)
)
```

---

# 반응형 레이아웃

## MediaQuery (화면 크기 확인)

```dart
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    body: screenWidth > 600
        ? _buildTabletLayout()  // 태블릿
        : _buildPhoneLayout(),  // 폰
  );
}
```

## LayoutBuilder

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 800) {
      // 넓은 화면: 2열 레이아웃
      return Row(
        children: [
          Expanded(flex: 1, child: _buildSidebar()),
          Expanded(flex: 3, child: _buildContent()),
        ],
      );
    } else {
      // 좁은 화면: 1열 레이아웃
      return _buildContent();
    }
  },
)
```

## 반응형 그리드

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _getCrossAxisCount(context),
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: 20,
  itemBuilder: (context, index) => Card(child: Center(child: Text('$index'))),
)

int _getCrossAxisCount(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 4;
  if (width > 800) return 3;
  if (width > 600) return 2;
  return 1;
}
```

---

# 실습 예제: 테마 전환 앱

```dart
import 'package:flutter/material.dart';

class ThemeSwitchApp extends StatefulWidget {
  const ThemeSwitchApp({super.key});

  @override
  State<ThemeSwitchApp> createState() => _ThemeSwitchAppState();
}

class _ThemeSwitchAppState extends State<ThemeSwitchApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('테마 전환'),
          actions: [
            IconButton(
              icon: Icon(
                _themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '현재 테마: ${_themeMode == ThemeMode.light ? "라이트" : "다크"}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleTheme,
                child: const Text('테마 변경'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
