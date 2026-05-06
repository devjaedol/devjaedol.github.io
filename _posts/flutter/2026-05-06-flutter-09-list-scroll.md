---
title: "[Flutter] 09. 리스트와 스크롤 - ListView, GridView"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

스크롤 가능한 리스트와 그리드를 만드는 방법을 배웁니다.

# ListView

## 기본 ListView

적은 수의 아이템에 적합합니다.

```dart
ListView(
  children: const [
    ListTile(
      leading: Icon(Icons.email),
      title: Text('이메일'),
      subtitle: Text('user@example.com'),
      trailing: Icon(Icons.arrow_forward_ios),
    ),
    ListTile(
      leading: Icon(Icons.phone),
      title: Text('전화번호'),
      subtitle: Text('010-1234-5678'),
    ),
    ListTile(
      leading: Icon(Icons.location_on),
      title: Text('주소'),
      subtitle: Text('서울시 강남구'),
    ),
  ],
)
```

## ListView.builder (대량 데이터)

필요한 아이템만 생성하여 메모리 효율적입니다.

```dart
class TodoListPage extends StatelessWidget {
  final List<String> items = List.generate(100, (i) => '할일 ${i + 1}');

  TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('할일 목록')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(items[index]),
            onTap: () {
              print('${items[index]} 선택');
            },
          );
        },
      ),
    );
  }
}
```

## ListView.separated (구분선 포함)

```dart
ListView.separated(
  itemCount: 20,
  separatorBuilder: (context, index) => const Divider(), // 구분선
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('아이템 $index'),
    );
  },
)
```

---

# GridView

## GridView.count (고정 열 수)

```dart
GridView.count(
  crossAxisCount: 2,        // 2열
  crossAxisSpacing: 10,     // 가로 간격
  mainAxisSpacing: 10,      // 세로 간격
  padding: const EdgeInsets.all(10),
  children: List.generate(6, (index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100 * (index % 9 + 1)],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('아이템 $index', style: const TextStyle(fontSize: 16)),
      ),
    );
  }),
)
```

## GridView.builder (대량 데이터)

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,       // 3열
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0,   // 가로:세로 비율
  ),
  itemCount: 30,
  padding: const EdgeInsets.all(8),
  itemBuilder: (context, index) {
    return Card(
      child: Center(child: Text('$index')),
    );
  },
)
```

---

# SingleChildScrollView

Column 등 스크롤이 안 되는 위젯을 스크롤 가능하게 만듭니다.

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Container(height: 200, color: Colors.red),
      const SizedBox(height: 16),
      Container(height: 200, color: Colors.green),
      const SizedBox(height: 16),
      Container(height: 200, color: Colors.blue),
      const SizedBox(height: 16),
      Container(height: 200, color: Colors.orange),
    ],
  ),
)
```

---

# 실습 예제: 연락처 앱

```dart
import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String phone;
  final String email;

  Contact({required this.name, required this.phone, required this.email});
}

class ContactListPage extends StatelessWidget {
  ContactListPage({super.key});

  final List<Contact> contacts = [
    Contact(name: '홍길동', phone: '010-1111-2222', email: 'hong@test.com'),
    Contact(name: '김철수', phone: '010-3333-4444', email: 'kim@test.com'),
    Contact(name: '이영희', phone: '010-5555-6666', email: 'lee@test.com'),
    Contact(name: '박민수', phone: '010-7777-8888', email: 'park@test.com'),
    Contact(name: '정수진', phone: '010-9999-0000', email: 'jung@test.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('연락처')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  contact.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  print('${contact.name}에게 전화');
                },
              ),
              onTap: () {
                print('${contact.name} 상세 보기');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('연락처 추가');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
