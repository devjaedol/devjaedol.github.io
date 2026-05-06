---
title: "[Flutter] 14. 로컬 저장소 - SharedPreferences, SQLite"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

앱 내부에 데이터를 저장하는 방법을 배웁니다.

# 저장 방식 비교

| 방식 | 용도 | 데이터 형태 |
|:---:|:---:|:---:|
| SharedPreferences | 간단한 설정값 | key-value |
| SQLite (sqflite) | 구조화된 대량 데이터 | 테이블 |
| Hive | 빠른 NoSQL 저장 | 객체 |
| 파일 저장 | 텍스트, JSON 파일 | 파일 |

---

# SharedPreferences

간단한 설정값(로그인 상태, 테마 설정 등)을 저장합니다.

## 설치

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.0
```

## 사용법

```dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  // 저장
  static Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  // 읽기
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // 삭제
  static Future<void> removeUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  // 다양한 타입 저장
  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', '홍길동');
    await prefs.setInt('age', 25);
    await prefs.setDouble('height', 175.5);
    await prefs.setBool('darkMode', true);
    await prefs.setStringList('favorites', ['Flutter', 'Dart']);
  }
}
```

## 실습: 자동 로그인

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _login(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    setState(() {
      _isLoggedIn = false;
      _username = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('환영합니다, $_username님!'),
              ElevatedButton(onPressed: _logout, child: const Text('로그아웃')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _login('홍길동'),
          child: const Text('로그인'),
        ),
      ),
    );
  }
}
```

---

# SQLite (sqflite)

구조화된 데이터를 테이블 형태로 저장합니다.

## 설치

```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.0
```

## 데이터베이스 헬퍼

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // 싱글톤 패턴
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'memo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
```

## CRUD 구현

```dart
class Memo {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  Memo({this.id, required this.title, required this.content, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class MemoRepository {
  // 생성 (Create)
  Future<int> insert(Memo memo) async {
    final db = await DatabaseHelper.database;
    return await db.insert('memos', memo.toMap());
  }

  // 조회 (Read)
  Future<List<Memo>> getAll() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memos',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  // 수정 (Update)
  Future<int> update(Memo memo) async {
    final db = await DatabaseHelper.database;
    return await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  // 삭제 (Delete)
  Future<int> delete(int id) async {
    final db = await DatabaseHelper.database;
    return await db.delete(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 검색
  Future<List<Memo>> search(String keyword) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'memos',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => Memo.fromMap(map)).toList();
  }
}
```

## 화면에서 사용

```dart
class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key});

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  final MemoRepository _repo = MemoRepository();
  List<Memo> _memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final memos = await _repo.getAll();
    setState(() => _memos = memos);
  }

  Future<void> _addMemo() async {
    await _repo.insert(Memo(
      title: '새 메모',
      content: '내용을 입력하세요',
      createdAt: DateTime.now(),
    ));
    _loadMemos(); // 목록 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메모')),
      body: ListView.builder(
        itemCount: _memos.length,
        itemBuilder: (context, index) {
          final memo = _memos[index];
          return ListTile(
            title: Text(memo.title),
            subtitle: Text(memo.content),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
