---
title: "[Flutter] 13. HTTP 통신 - REST API 연동"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter에서 서버와 HTTP 통신하여 데이터를 주고받는 방법을 배웁니다.

# http 패키지 설치

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

```bash
flutter pub get
```

---

# GET 요청 (데이터 조회)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// 사용자 목록 가져오기
Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  );

  if (response.statusCode == 200) {
    // JSON 파싱
    List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('데이터 로드 실패: ${response.statusCode}');
  }
}
```

---

# POST 요청 (데이터 생성)

```dart
Future<Map<String, dynamic>> createPost({
  required String title,
  required String body,
  required int userId,
}) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': title,
      'body': body,
      'userId': userId,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('생성 실패: ${response.statusCode}');
  }
}
```

---

# 모델 클래스 활용

## JSON → Dart 객체 변환

```dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // JSON → User 객체
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  // User 객체 → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// 사용
Future<List<User>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('로드 실패');
  }
}
```

---

# FutureBuilder로 UI 연결

비동기 데이터를 화면에 표시하는 위젯입니다.

```dart
import 'package:flutter/material.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 목록')),
      body: FutureBuilder<List<User>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 발생
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }

          // 데이터 없음
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          // 데이터 표시
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${user.id}')),
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

# API 서비스 클래스 패턴

실제 앱에서는 API 호출을 별도 클래스로 분리합니다.

```dart
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET: 목록 조회
  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  // GET: 단건 조회
  Future<User> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user');
  }

  // POST: 생성
  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create user');
  }

  // PUT: 수정
  Future<User> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update user');
  }

  // DELETE: 삭제
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
```

---

# 에러 처리 패턴

```dart
Future<void> loadData() async {
  try {
    final users = await ApiService().getUsers();
    // 성공 처리
  } on SocketException {
    // 네트워크 연결 없음
    print('인터넷 연결을 확인하세요');
  } on HttpException {
    // HTTP 오류
    print('서버 오류가 발생했습니다');
  } on FormatException {
    // JSON 파싱 오류
    print('데이터 형식 오류');
  } catch (e) {
    // 기타 오류
    print('오류: $e');
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
