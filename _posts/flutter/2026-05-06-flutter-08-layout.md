---
title: "[Flutter] 08. 레이아웃 - Row, Column, Stack"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter에서 위젯을 배치하는 레이아웃 위젯을 배웁니다.

# 레이아웃 기본 개념

Flutter는 CSS가 아닌 위젯 조합으로 레이아웃을 구성합니다.

| 레이아웃 위젯 | 방향 | 설명 |
|:---:|:---:|:---:|
| Row | 가로 (→) | 자식을 수평 배치 |
| Column | 세로 (↓) | 자식을 수직 배치 |
| Stack | 겹침 | 자식을 겹쳐서 배치 |

---

# Column (세로 배치)

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,    // 세로 정렬
  crossAxisAlignment: CrossAxisAlignment.start,   // 가로 정렬
  children: [
    Text('첫 번째'),
    Text('두 번째'),
    Text('세 번째'),
  ],
)
```

## MainAxisAlignment (주축 정렬)

Column에서 주축은 세로 방향입니다.

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.start,         // 위쪽 정렬 (기본)
  // MainAxisAlignment.center,       // 가운데 정렬
  // MainAxisAlignment.end,          // 아래쪽 정렬
  // MainAxisAlignment.spaceBetween, // 균등 배치 (양 끝 붙임)
  // MainAxisAlignment.spaceEvenly,  // 균등 배치 (동일 간격)
  // MainAxisAlignment.spaceAround,  // 균등 배치 (양 끝 절반 간격)
  children: [...],
)
```

## CrossAxisAlignment (교차축 정렬)

Column에서 교차축은 가로 방향입니다.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,   // 왼쪽 정렬
  // CrossAxisAlignment.center,  // 가운데 정렬 (기본)
  // CrossAxisAlignment.end,     // 오른쪽 정렬
  // CrossAxisAlignment.stretch, // 가로 꽉 채움
  children: [...],
)
```

---

# Row (가로 배치)

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 가로 정렬
  crossAxisAlignment: CrossAxisAlignment.center,    // 세로 정렬
  children: [
    Icon(Icons.star, color: Colors.red),
    Icon(Icons.star, color: Colors.green),
    Icon(Icons.star, color: Colors.blue),
  ],
)
```

> Row에서 주축은 가로, 교차축은 세로입니다. Column과 반대!

---

# Expanded / Flexible

남은 공간을 비율로 나눠 차지합니다.

```dart
Row(
  children: [
    // flex 비율로 공간 분배
    Expanded(
      flex: 2, // 2/3 차지
      child: Container(color: Colors.red, height: 50),
    ),
    Expanded(
      flex: 1, // 1/3 차지
      child: Container(color: Colors.blue, height: 50),
    ),
  ],
)
```

```dart
Row(
  children: [
    // Flexible: 필요한 만큼만 차지 (남은 공간 비움)
    Flexible(
      child: Text('짧은 텍스트'),
    ),
    // Expanded: 남은 공간 모두 차지
    Expanded(
      child: Text('이 텍스트는 남은 공간을 모두 차지합니다'),
    ),
  ],
)
```

---

# Stack (겹쳐서 배치)

위젯을 겹쳐서 배치합니다. 배경 위에 텍스트를 올리거나 뱃지를 표시할 때 사용합니다.

```dart
Stack(
  children: [
    // 가장 아래 (배경)
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    // 위에 겹침
    Positioned(
      top: 10,
      left: 10,
      child: Text(
        'Hello',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
    // 오른쪽 아래에 배치
    Positioned(
      bottom: 10,
      right: 10,
      child: Icon(Icons.star, color: Colors.yellow),
    ),
  ],
)
```

---

# Container (박스 모델)

크기, 여백, 패딩, 색상, 테두리를 설정하는 만능 위젯입니다.

```dart
Container(
  width: 200,
  height: 100,
  margin: const EdgeInsets.all(16),       // 바깥 여백
  padding: const EdgeInsets.all(12),      // 안쪽 여백
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12), // 둥근 모서리
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
    border: Border.all(color: Colors.grey),  // 테두리
  ),
  child: const Text('카드 형태'),
)
```

---

# Padding / Margin

```dart
// Padding 위젯 (안쪽 여백만)
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16, // 좌우
    vertical: 8,    // 상하
  ),
  child: Text('패딩 적용'),
)

// EdgeInsets 종류
EdgeInsets.all(16)                    // 상하좌우 동일
EdgeInsets.only(top: 10, left: 20)   // 개별 지정
EdgeInsets.symmetric(horizontal: 16) // 대칭
EdgeInsets.fromLTRB(10, 20, 10, 20)  // Left, Top, Right, Bottom
```

---

# 실습 예제: 프로필 카드

```dart
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 프로필 이미지
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // 이름
              const Text(
                '홍길동',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // 직업
              Text(
                'Flutter 개발자',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // 정보 Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfo('게시글', '128'),
                  _buildInfo('팔로워', '1.2K'),
                  _buildInfo('팔로잉', '356'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
