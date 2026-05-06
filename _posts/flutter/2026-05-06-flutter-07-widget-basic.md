---
title: "[Flutter] 07. 위젯 기초 - StatelessWidget, StatefulWidget"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter의 핵심 개념인 위젯(Widget)의 기본 구조와 종류를 배웁니다.

# 위젯이란?

Flutter에서 화면에 보이는 모든 것은 위젯입니다.  
버튼, 텍스트, 이미지, 레이아웃 등 모든 UI 요소가 위젯으로 구성됩니다.

## 위젯 트리 구조

```
MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text('제목')
    └── Body
        └── Column
            ├── Text('안녕하세요')
            ├── Image(...)
            └── ElevatedButton(...)
```

---

# StatelessWidget

상태가 변하지 않는 위젯입니다. 한 번 그려지면 변경되지 않습니다.

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
      home: Scaffold(
        appBar: AppBar(title: const Text('첫 번째 앱')),
        body: const Center(
          child: Text(
            '안녕하세요, Flutter!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

## StatelessWidget 구조

```dart
class MyWidget extends StatelessWidget {
  // 1. 생성자
  const MyWidget({super.key});

  // 2. build 메서드 (UI 반환)
  @override
  Widget build(BuildContext context) {
    return 위젯;
  }
}
```

---

# StatefulWidget

상태가 변할 수 있는 위젯입니다. 사용자 입력, 데이터 변경 시 화면을 다시 그립니다.

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
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0; // 상태 변수

  void _increment() {
    setState(() {
      _count++; // setState 안에서 상태 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카운터')),
      body: Center(
        child: Text(
          '$_count',
          style: const TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## StatefulWidget 구조

```dart
// 1. Widget 클래스 (불변)
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

// 2. State 클래스 (가변 상태 관리)
class _MyWidgetState extends State<MyWidget> {
  // 상태 변수 선언
  int value = 0;

  // 상태 변경 시 setState() 호출
  void updateValue() {
    setState(() {
      value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 위젯;
  }
}
```

---

# StatelessWidget vs StatefulWidget

| 항목 | StatelessWidget | StatefulWidget |
|:---:|:---:|:---:|
| 상태 변경 | 불가 | 가능 |
| 리빌드 | 부모가 변경될 때만 | setState() 호출 시 |
| 용도 | 고정 UI (아이콘, 텍스트) | 동적 UI (입력, 애니메이션) |
| 성능 | 더 가벼움 | 상태 관리 오버헤드 |

> 가능하면 StatelessWidget을 사용하고, 상태 변경이 필요할 때만 StatefulWidget을 사용합니다.

---

# 위젯 생명주기

## StatefulWidget 생명주기

```dart
class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // 위젯 생성 시 1번 호출 (초기화)
    print('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 의존성 변경 시 호출
    print('didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    // UI 빌드 (setState마다 호출)
    print('build');
    return Container();
  }

  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 부모 위젯이 변경될 때 호출
    print('didUpdateWidget');
  }

  @override
  void dispose() {
    // 위젯 제거 시 호출 (정리 작업)
    print('dispose');
    super.dispose();
  }
}
```

### 생명주기 순서

```
생성: initState → didChangeDependencies → build
갱신: setState → build
제거: dispose
```

---

# 기본 위젯 소개

| 위젯 | 용도 | 예시 |
|------|------|------|
| `Text` | 텍스트 표시 | `Text('안녕')` |
| `Icon` | 아이콘 표시 | `Icon(Icons.star)` |
| `Image` | 이미지 표시 | `Image.network(url)` |
| `ElevatedButton` | 버튼 | `ElevatedButton(onPressed: ..., child: ...)` |
| `TextField` | 텍스트 입력 | `TextField(controller: ...)` |
| `Container` | 박스 (크기, 색상, 여백) | `Container(width: 100, color: Colors.blue)` |
| `SizedBox` | 고정 크기 공간 | `SizedBox(height: 20)` |

## 기본 위젯 예시

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('기본 위젯')),
    body: Column(
      children: [
        // 텍스트
        const Text(
          'Flutter 학습',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20), // 간격

        // 아이콘
        const Icon(Icons.flutter_dash, size: 50, color: Colors.blue),
        const SizedBox(height: 20),

        // 버튼
        ElevatedButton(
          onPressed: () {
            print('버튼 클릭!');
          },
          child: const Text('클릭하세요'),
        ),
      ],
    ),
  );
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
