---
title: "[Flutter] 01. Dart 언어 기초 - 변수, 타입, 연산자"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter 개발의 기본이 되는 Dart 언어의 변수, 타입, 연산자를 배웁니다.

# Dart 언어란?

Dart는 Google이 개발한 프로그래밍 언어로, Flutter의 공식 언어입니다.  
JavaScript와 Java의 장점을 결합한 현대적인 언어입니다.

## Dart 특징

| 특징 | 설명 |
|:---:|:---:|
| 타입 안전 | 컴파일 타임에 타입 오류 검출 |
| null safety | null 참조 오류 방지 |
| AOT 컴파일 | 네이티브 코드로 빠른 실행 |
| JIT 컴파일 | 개발 중 Hot Reload 지원 |
| 객체지향 | 클래스 기반 OOP |
| 비동기 지원 | async/await 내장 |

---

## Dart 설치 및 실행

### DartPad (온라인)
설치 없이 바로 실행 가능: [https://dartpad.dev](https://dartpad.dev){:target="_blank"}

### 로컬 설치
```bash
# Windows (Chocolatey)
choco install dart-sdk

# Mac (Homebrew)
brew tap dart-lang/dart
brew install dart

# 버전 확인
dart --version
```

### 첫 번째 프로그램
```dart
void main() {
  print('Hello, Dart!');
}
```
```bash
# 실행
dart run hello.dart
```

---

## 변수 선언

### var, final, const

```dart
void main() {
  // var: 타입 추론, 값 변경 가능
  var name = '홍길동';
  name = '김철수'; // OK

  // final: 런타임에 한 번만 할당
  final age = 25;
  // age = 30; // 에러! 변경 불가

  // const: 컴파일 타임 상수
  const pi = 3.14159;
  // const now = DateTime.now(); // 에러! 컴파일 타임에 결정 불가
  final now = DateTime.now(); // OK
}
```

### 명시적 타입 선언

```dart
void main() {
  String city = '서울';
  int count = 10;
  double price = 99.9;
  bool isActive = true;

  // late: 나중에 초기화
  late String description;
  description = '나중에 할당';
}
```

### var vs final vs const 비교

| 키워드 | 재할당 | 결정 시점 | 용도 |
|:---:|:---:|:---:|:---:|
| var | 가능 | 런타임 | 일반 변수 |
| final | 불가 | 런타임 | 한 번만 할당 |
| const | 불가 | 컴파일 타임 | 절대 변하지 않는 값 |

---

## 기본 데이터 타입

```dart
void main() {
  // 숫자
  int age = 30;
  double height = 175.5;
  num score = 95; // int 또는 double

  // 문자열
  String name = 'Dart';
  String greeting = "Hello, $name!"; // 문자열 보간
  String info = '나이: ${age + 1}세'; // 표현식

  // 불리언
  bool isFlutter = true;

  // 리스트 (배열)
  List<int> numbers = [1, 2, 3, 4, 5];
  var fruits = ['사과', '바나나', '포도'];

  // 맵 (딕셔너리)
  Map<String, int> scores = {
    '국어': 90,
    '영어': 85,
    '수학': 95,
  };

  // Set (중복 없는 집합)
  Set<String> colors = {'빨강', '파랑', '초록'};

  print(greeting);       // Hello, Dart!
  print(numbers[0]);     // 1
  print(scores['국어']); // 90
}
```

---

## Null Safety

Dart는 기본적으로 null을 허용하지 않습니다.

```dart
void main() {
  // 기본: null 불가
  String name = '홍길동';
  // name = null; // 에러!

  // nullable: ? 붙이면 null 허용
  String? nickname = null;
  nickname = '길동이';

  // null 체크
  if (nickname != null) {
    print(nickname.length); // 안전하게 접근
  }

  // ?? : null이면 기본값 사용
  String displayName = nickname ?? '이름없음';

  // ?. : null이면 호출 안 함
  int? length = nickname?.length;

  // ! : null 아님을 확신 (주의해서 사용)
  print(nickname!.length);
}
```

---

## 연산자

### 산술 연산자
```dart
void main() {
  int a = 10, b = 3;

  print(a + b);  // 13 (덧셈)
  print(a - b);  // 7  (뺄셈)
  print(a * b);  // 30 (곱셈)
  print(a / b);  // 3.333... (나눗셈, double 반환)
  print(a ~/ b); // 3  (정수 나눗셈)
  print(a % b);  // 1  (나머지)
}
```

### 비교 / 논리 연산자
```dart
void main() {
  // 비교
  print(5 == 5);  // true
  print(5 != 3);  // true
  print(5 > 3);   // true
  print(5 >= 5);  // true

  // 논리
  print(true && false); // false (AND)
  print(true || false); // true  (OR)
  print(!true);         // false (NOT)
}
```

### 할당 연산자
```dart
void main() {
  int x = 10;
  x += 5;  // x = x + 5 → 15
  x -= 3;  // x = x - 3 → 12
  x *= 2;  // x = x * 2 → 24

  // ??= : null일 때만 할당
  String? name;
  name ??= '기본값'; // name이 null이므로 '기본값' 할당
  name ??= '새값';   // name이 null이 아니므로 무시
  print(name); // 기본값
}
```

---

## 타입 변환

```dart
void main() {
  // 문자열 → 숫자
  int num1 = int.parse('42');
  double num2 = double.parse('3.14');

  // 숫자 → 문자열
  String str1 = 42.toString();
  String str2 = 3.14.toStringAsFixed(1); // '3.1'

  // int ↔ double
  double d = 10.toDouble(); // 10.0
  int i = 3.14.toInt();     // 3 (소수점 버림)

  print('$num1, $num2, $str1, $str2');
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
