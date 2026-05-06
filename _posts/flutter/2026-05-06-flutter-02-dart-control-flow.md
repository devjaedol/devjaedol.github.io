---
title: "[Flutter] 02. Dart 제어문 - 조건문, 반복문"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Dart의 조건문과 반복문을 배워 프로그램 흐름을 제어합니다.

# 조건문

## if / else if / else

```dart
void main() {
  int score = 85;

  if (score >= 90) {
    print('A등급');
  } else if (score >= 80) {
    print('B등급');
  } else if (score >= 70) {
    print('C등급');
  } else {
    print('F등급');
  }
  // 출력: B등급
}
```

## 삼항 연산자

```dart
void main() {
  int age = 20;
  String result = age >= 18 ? '성인' : '미성년자';
  print(result); // 성인
}
```

## switch / case

```dart
void main() {
  String grade = 'B';

  switch (grade) {
    case 'A':
      print('우수');
      break;
    case 'B':
      print('양호');
      break;
    case 'C':
      print('보통');
      break;
    default:
      print('노력 필요');
  }
  // 출력: 양호
}
```

### Dart 3.0+ 패턴 매칭 switch

```dart
void main() {
  int statusCode = 404;

  String message = switch (statusCode) {
    200 => '성공',
    301 => '리다이렉트',
    404 => '페이지 없음',
    500 => '서버 오류',
    _ => '알 수 없는 상태',
  };

  print(message); // 페이지 없음
}
```

---

# 반복문

## for 문

```dart
void main() {
  // 기본 for
  for (int i = 0; i < 5; i++) {
    print('반복 $i');
  }

  // for-in (컬렉션 순회)
  List<String> fruits = ['사과', '바나나', '포도'];
  for (String fruit in fruits) {
    print(fruit);
  }
}
```

## while / do-while

```dart
void main() {
  // while: 조건 먼저 확인
  int count = 0;
  while (count < 3) {
    print('while: $count');
    count++;
  }

  // do-while: 최소 1번 실행
  int num = 5;
  do {
    print('do-while: $num');
    num++;
  } while (num < 3); // 조건 false지만 1번은 실행됨
}
```

## break / continue

```dart
void main() {
  // break: 반복 중단
  for (int i = 0; i < 10; i++) {
    if (i == 5) break;
    print(i); // 0, 1, 2, 3, 4
  }

  // continue: 현재 반복 건너뛰기
  for (int i = 0; i < 5; i++) {
    if (i == 2) continue;
    print(i); // 0, 1, 3, 4
  }
}
```

---

# 컬렉션 메서드 활용

## List 주요 메서드

```dart
void main() {
  List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // forEach: 각 요소에 대해 실행
  numbers.forEach((n) => print(n));

  // map: 변환
  var doubled = numbers.map((n) => n * 2).toList();
  print(doubled); // [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

  // where: 필터링
  var evens = numbers.where((n) => n % 2 == 0).toList();
  print(evens); // [2, 4, 6, 8, 10]

  // any / every: 조건 확인
  print(numbers.any((n) => n > 5));   // true
  print(numbers.every((n) => n > 0)); // true

  // reduce: 누적 계산
  int sum = numbers.reduce((a, b) => a + b);
  print(sum); // 55
}
```

## Map 순회

```dart
void main() {
  Map<String, int> scores = {
    '국어': 90,
    '영어': 85,
    '수학': 95,
  };

  // entries로 순회
  for (var entry in scores.entries) {
    print('${entry.key}: ${entry.value}점');
  }

  // forEach
  scores.forEach((key, value) {
    print('$key: $value점');
  });

  // keys, values
  print(scores.keys.toList());   // [국어, 영어, 수학]
  print(scores.values.toList()); // [90, 85, 95]
}
```

---

# 실습 예제

## 구구단 출력

```dart
void main() {
  for (int i = 2; i <= 9; i++) {
    print('--- $i단 ---');
    for (int j = 1; j <= 9; j++) {
      print('$i x $j = ${i * j}');
    }
  }
}
```

## 성적 처리

```dart
void main() {
  List<int> scores = [85, 92, 78, 96, 88, 73, 91];

  // 평균 계산
  double avg = scores.reduce((a, b) => a + b) / scores.length;
  print('평균: ${avg.toStringAsFixed(1)}');

  // 80점 이상 필터링
  var passed = scores.where((s) => s >= 80).toList();
  print('합격자 수: ${passed.length}명');

  // 최고점, 최저점
  scores.sort();
  print('최저: ${scores.first}, 최고: ${scores.last}');
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
