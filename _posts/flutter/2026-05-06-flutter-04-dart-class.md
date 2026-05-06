---
title: "[Flutter] 04. Dart 클래스 - OOP 기초"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Dart의 클래스와 객체지향 프로그래밍(OOP) 기초를 배웁니다. Flutter 위젯은 모두 클래스이므로 반드시 이해해야 합니다.

# 클래스 기본

## 클래스 선언과 인스턴스 생성

```dart
class Person {
  // 속성 (필드)
  String name;
  int age;

  // 생성자
  Person(this.name, this.age);

  // 메서드
  void introduce() {
    print('안녕하세요, $name입니다. $age세입니다.');
  }
}

void main() {
  var person = Person('홍길동', 25);
  person.introduce(); // 안녕하세요, 홍길동입니다. 25세입니다.

  print(person.name); // 홍길동
  person.age = 26;    // 속성 변경
}
```

---

## 생성자 종류

### 기본 생성자

```dart
class User {
  String name;
  int age;
  String role;

  // 축약 생성자 (Dart 스타일)
  User(this.name, this.age, {this.role = '일반'});
}

void main() {
  var user = User('홍길동', 25, role: '관리자');
}
```

### Named 생성자

```dart
class Point {
  double x, y;

  Point(this.x, this.y);

  // Named 생성자
  Point.origin() : x = 0, y = 0;
  Point.fromJson(Map<String, double> json)
      : x = json['x'] ?? 0,
        y = json['y'] ?? 0;

  @override
  String toString() => 'Point($x, $y)';
}

void main() {
  var p1 = Point(3, 4);
  var p2 = Point.origin();
  var p3 = Point.fromJson({'x': 5.0, 'y': 10.0});

  print(p1); // Point(3.0, 4.0)
  print(p2); // Point(0.0, 0.0)
  print(p3); // Point(5.0, 10.0)
}
```

### const 생성자

```dart
class Color {
  final int r, g, b;

  const Color(this.r, this.g, this.b);

  // 미리 정의된 상수
  static const Color red = Color(255, 0, 0);
  static const Color green = Color(0, 255, 0);
  static const Color blue = Color(0, 0, 255);
}

void main() {
  const c1 = Color(255, 0, 0);
  const c2 = Color.red;
  print(identical(c1, c2)); // true (같은 객체)
}
```

---

## 접근 제어

Dart는 `_` (언더스코어)로 private을 표현합니다.

```dart
class BankAccount {
  String owner;
  double _balance; // private (같은 파일 내에서만 접근)

  BankAccount(this.owner, this._balance);

  // getter
  double get balance => _balance;

  // setter
  set balance(double value) {
    if (value >= 0) _balance = value;
  }

  // 메서드
  void deposit(double amount) {
    if (amount > 0) _balance += amount;
  }

  void withdraw(double amount) {
    if (amount > 0 && amount <= _balance) {
      _balance -= amount;
    }
  }
}

void main() {
  var account = BankAccount('홍길동', 10000);
  account.deposit(5000);
  account.withdraw(3000);
  print(account.balance); // 12000.0
}
```

---

# 상속과 다형성

## extends (상속)

```dart
class Animal {
  String name;
  Animal(this.name);

  void speak() {
    print('$name이(가) 소리를 냅니다.');
  }
}

class Dog extends Animal {
  Dog(String name) : super(name);

  @override
  void speak() {
    print('$name: 멍멍!');
  }

  void fetch() {
    print('$name이(가) 공을 가져옵니다.');
  }
}

class Cat extends Animal {
  Cat(String name) : super(name);

  @override
  void speak() {
    print('$name: 야옹~');
  }
}

void main() {
  Animal dog = Dog('바둑이');
  Animal cat = Cat('나비');

  dog.speak(); // 바둑이: 멍멍!
  cat.speak(); // 나비: 야옹~
}
```

## abstract class (추상 클래스)

```dart
abstract class Shape {
  double area();       // 추상 메서드 (구현 필수)
  double perimeter();  // 추상 메서드

  void printInfo() {   // 일반 메서드
    print('넓이: ${area()}, 둘레: ${perimeter()}');
  }
}

class Circle extends Shape {
  double radius;
  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;

  @override
  double perimeter() => 2 * 3.14159 * radius;
}

class Rectangle extends Shape {
  double width, height;
  Rectangle(this.width, this.height);

  @override
  double area() => width * height;

  @override
  double perimeter() => 2 * (width + height);
}

void main() {
  List<Shape> shapes = [Circle(5), Rectangle(4, 6)];
  for (var shape in shapes) {
    shape.printInfo();
  }
}
```

## mixin (믹스인)

다중 상속 대신 사용하는 코드 재사용 방법:

```dart
mixin Flyable {
  void fly() => print('날고 있습니다!');
}

mixin Swimmable {
  void swim() => print('수영하고 있습니다!');
}

class Duck extends Animal with Flyable, Swimmable {
  Duck(String name) : super(name);
}

void main() {
  var duck = Duck('도널드');
  duck.speak(); // 도널드이(가) 소리를 냅니다.
  duck.fly();   // 날고 있습니다!
  duck.swim();  // 수영하고 있습니다!
}
```

---

# 실습 예제

## 간단한 할일 관리

```dart
class Todo {
  String title;
  bool isDone;
  DateTime createdAt;

  Todo(this.title)
      : isDone = false,
        createdAt = DateTime.now();

  void toggle() => isDone = !isDone;

  @override
  String toString() => '[${isDone ? "✓" : " "}] $title';
}

class TodoList {
  final List<Todo> _todos = [];

  void add(String title) => _todos.add(Todo(title));

  void complete(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos[index].toggle();
    }
  }

  void printAll() {
    for (int i = 0; i < _todos.length; i++) {
      print('$i: ${_todos[i]}');
    }
    print('완료: ${_todos.where((t) => t.isDone).length}/${_todos.length}');
  }
}

void main() {
  var list = TodoList();
  list.add('Flutter 설치');
  list.add('Dart 문법 공부');
  list.add('첫 번째 앱 만들기');

  list.complete(0);
  list.complete(1);
  list.printAll();
  // 0: [✓] Flutter 설치
  // 1: [✓] Dart 문법 공부
  // 2: [ ] 첫 번째 앱 만들기
  // 완료: 2/3
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
