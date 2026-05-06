---
title: "[Flutter] 10. 화면 이동 - Navigation, Route"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter에서 화면 간 이동(Navigation)하는 방법을 배웁니다.

# Navigation 기본

Flutter는 스택(Stack) 구조로 화면을 관리합니다.

```
push: 새 화면을 스택 위에 추가
pop: 현재 화면을 스택에서 제거 (뒤로 가기)
```

---

# Navigator.push / pop

## 기본 화면 이동

```dart
import 'package:flutter/material.dart';

// 첫 번째 화면
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('첫 번째 화면')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 두 번째 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondPage()),
            );
          },
          child: const Text('다음 화면으로'),
        ),
      ),
    );
  }
}

// 두 번째 화면
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('두 번째 화면')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 이전 화면으로 돌아가기
            Navigator.pop(context);
          },
          child: const Text('뒤로 가기'),
        ),
      ),
    );
  }
}
```

---

# 데이터 전달

## 다음 화면으로 데이터 전달

```dart
class DetailPage extends StatelessWidget {
  final String title;
  final int id;

  const DetailPage({super.key, required this.title, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('ID: $id')),
    );
  }
}

// 이동 시 데이터 전달
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DetailPage(title: '상세 페이지', id: 42),
  ),
);
```

## 이전 화면으로 결과 반환

```dart
// 두 번째 화면에서 결과 반환
Navigator.pop(context, '선택된 값');

// 첫 번째 화면에서 결과 받기
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SelectPage()),
);
if (result != null) {
  print('받은 결과: $result');
}
```

---

# Named Routes

## 라우트 정의

```dart
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/detail': (context) => const DetailPage(),
      '/settings': (context) => const SettingsPage(),
    },
  ));
}
```

## Named Route로 이동

```dart
// 이동
Navigator.pushNamed(context, '/detail');

// 데이터 전달
Navigator.pushNamed(
  context,
  '/detail',
  arguments: {'id': 1, 'title': '제목'},
);

// 데이터 받기 (대상 화면에서)
final args = ModalRoute.of(context)!.settings.arguments as Map;
print(args['title']);
```

---

# pushReplacement / pushAndRemoveUntil

## pushReplacement (현재 화면 교체)

로그인 후 홈 화면으로 이동할 때 사용합니다.

```dart
// 현재 화면을 새 화면으로 교체 (뒤로 가기 불가)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomePage()),
);
```

## pushAndRemoveUntil (스택 초기화)

```dart
// 모든 이전 화면 제거 후 이동 (로그아웃 시)
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const LoginPage()),
  (route) => false, // 모든 이전 라우트 제거
);
```

---

# 실습 예제: 간단한 앱 네비게이션

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
      title: '네비게이션 예제',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> menuItems = const [
    {'title': '프로필', 'icon': 'person'},
    {'title': '설정', 'icon': 'settings'},
    {'title': '알림', 'icon': 'notifications'},
    {'title': '도움말', 'icon': 'help'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.circle),
            title: Text(menuItems[index]['title']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    title: menuItems[index]['title']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$title 페이지', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
