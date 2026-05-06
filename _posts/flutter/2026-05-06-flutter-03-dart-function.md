---
title: "[Flutter] 03. Dart 함수 - 선언, 매개변수, 람다"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Dart의 함수 선언 방법과 다양한 매개변수 활용법을 배웁니다.

# 함수 기본

## 함수 선언

```dart
// 기본 형태
반환타입 함수명(매개변수) {
  // 본문
  return 값;
}
```

```dart
// 예시
int add(int a, int b) {
  return a + b;
}

void sayHello(String name) {
  print('안녕하세요, $name님!');
}

void main() {
  int result = add(3, 5);
  print(result); // 8
  sayHello('홍길동'); // 안녕하세요, 홍길동님!
}
```

## 화살표 함수 (Arrow Function)

한 줄로 표현 가능한 함수는 `=>` 사용:

```dart
int add(int a, int b) => a + b;
void greet(String name) => print('Hello, $name!');
bool isEven(int n) => n % 2 == 0;

void main() {
  print(add(10, 20)); // 30
  print(isEven(4));   // true
}
```

---

# 매개변수 종류

## 위치 매개변수 (Positional)

```dart
// 필수 위치 매개변수
String introduce(String name, int age) {
  return '$name, $age세';
}

void main() {
  print(introduce('홍길동', 25)); // 홍길동, 25세
}
```

## 선택적 위치 매개변수 (Optional Positional)

`[]`로 감싸면 선택적:

```dart
String greet(String name, [String? title, String suffix = '님']) {
  if (title != null) {
    return '$title $name$suffix';
  }
  return '$name$suffix';
}

void main() {
  print(greet('홍길동'));           // 홍길동님
  print(greet('홍길동', '교수'));    // 교수 홍길동님
}
```

## 이름 있는 매개변수 (Named Parameters)

`{}`로 감싸면 이름으로 전달. Flutter에서 가장 많이 사용됩니다.

```dart
// required: 필수, 기본값 없으면 반드시 전달
void createUser({
  required String name,
  required int age,
  String role = '일반',  // 기본값
  String? email,         // 선택적
}) {
  print('이름: $name, 나이: $age, 역할: $role');
  if (email != null) print('이메일: $email');
}

void main() {
  createUser(name: '홍길동', age: 25);
  createUser(
    name: '김철수',
    age: 30,
    role: '관리자',
    email: 'kim@test.com',
  );
}
```

> Flutter 위젯에서 Named Parameters를 매우 많이 사용합니다.  
> `Text('Hello', style: TextStyle(fontSize: 20))` 같은 형태입니다.

---

# 고급 함수 활용

## 일급 객체 (First-class Function)

함수를 변수에 저장하거나 매개변수로 전달할 수 있습니다.

```dart
void main() {
  // 함수를 변수에 저장
  var multiply = (int a, int b) => a * b;
  print(multiply(3, 4)); // 12

  // 함수를 매개변수로 전달
  List<int> numbers = [1, 2, 3, 4, 5];
  var result = numbers.map((n) => n * 10).toList();
  print(result); // [10, 20, 30, 40, 50]
}
```

## typedef (함수 타입 정의)

```dart
typedef MathOperation = int Function(int, int);

int add(int a, int b) => a + b;
int subtract(int a, int b) => a - b;

int calculate(int a, int b, MathOperation operation) {
  return operation(a, b);
}

void main() {
  print(calculate(10, 3, add));      // 13
  print(calculate(10, 3, subtract)); // 7
}
```

## 클로저 (Closure)

```dart
Function makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

void main() {
  var counter = makeCounter();
  print(counter()); // 1
  print(counter()); // 2
  print(counter()); // 3
}
```

---

# 실습 예제

## 계산기 함수

```dart
double calculate(double a, double b, String operator) {
  return switch (operator) {
    '+' => a + b,
    '-' => a - b,
    '*' => a * b,
    '/' => b != 0 ? a / b : 0,
    _ => throw ArgumentError('잘못된 연산자: $operator'),
  };
}

void main() {
  print(calculate(10, 3, '+')); // 13.0
  print(calculate(10, 3, '-')); // 7.0
  print(calculate(10, 3, '*')); // 30.0
  print(calculate(10, 3, '/')); // 3.333...
}
```

## 리스트 필터 함수

```dart
List<T> filterList<T>(List<T> items, bool Function(T) test) {
  List<T> result = [];
  for (var item in items) {
    if (test(item)) result.add(item);
  }
  return result;
}

void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  var evens = filterList(numbers, (n) => n % 2 == 0);
  print(evens); // [2, 4, 6, 8, 10]

  var names = ['홍길동', '김', '이순신', '박'];
  var longNames = filterList(names, (n) => n.length >= 3);
  print(longNames); // [홍길동, 이순신]
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
