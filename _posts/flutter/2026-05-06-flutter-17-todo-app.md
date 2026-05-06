---
title: "[Flutter] 17. 실전 프로젝트 - Todo 앱 만들기"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

지금까지 배운 내용을 종합하여 완성도 있는 Todo 앱을 만듭니다.

# 프로젝트 구조

```
lib/
├── main.dart           # 앱 진입점
├── models/
│   └── todo.dart       # Todo 모델
├── screens/
│   ├── todo_list_screen.dart  # 목록 화면
│   └── todo_add_screen.dart   # 추가 화면
└── widgets/
    └── todo_item.dart  # Todo 아이템 위젯
```

---

# 1. 모델 정의

```dart
// lib/models/todo.dart
class Todo {
  final String id;
  String title;
  String? description;
  bool isDone;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
  });
}
```

---

# 2. 메인 앱

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

# 3. Todo 아이템 위젯

```dart
// lib/widgets/todo_item.dart
import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        // 체크박스
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => onToggle(),
          shape: const CircleBorder(),
        ),
        // 제목
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : null,
          ),
        ),
        // 설명
        subtitle: todo.description != null
            ? Text(
                todo.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        // 삭제 버튼
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
```

---

# 4. 목록 화면

```dart
// lib/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'todo_add_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];

  // 완료/미완료 개수
  int get _doneCount => _todos.where((t) => t.isDone).length;
  int get _totalCount => _todos.length;

  // 완료 토글
  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  // 삭제
  void _deleteTodo(int index) {
    final deleted = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });

    // 되돌리기 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deleted.title}" 삭제됨'),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () {
            setState(() {
              _todos.insert(index, deleted);
            });
          },
        ),
      ),
    );
  }

  // 추가 화면으로 이동
  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(builder: (context) => const TodoAddScreen()),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 목록'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_doneCount / $_totalCount',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('할일이 없습니다', style: TextStyle(color: Colors.grey)),
                  Text('+ 버튼을 눌러 추가하세요', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _todos.length,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemBuilder: (context, index) {
                return TodoItem(
                  todo: _todos[index],
                  onToggle: () => _toggleTodo(index),
                  onDelete: () => _deleteTodo(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

# 5. 추가 화면

```dart
// lib/screens/todo_add_screen.dart
import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoAddScreen extends StatefulWidget {
  const TodoAddScreen({super.key});

  @override
  State<TodoAddScreen> createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        createdAt: DateTime.now(),
      );
      Navigator.pop(context, todo); // 결과 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 추가'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '할일 제목',
                  hintText: '무엇을 해야 하나요?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '상세 내용을 입력하세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('추가하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

# 완성된 앱 기능 요약

| 기능 | 구현 내용 |
|------|----------|
| 할일 추가 | Form 유효성 검사 + Navigator 결과 반환 |
| 할일 완료 | Checkbox + setState |
| 할일 삭제 | 삭제 + SnackBar 되돌리기 |
| 빈 상태 | 할일 없을 때 안내 메시지 |
| 진행률 | AppBar에 완료/전체 표시 |

> 이 프로젝트에 Provider 상태관리, SQLite 저장, 카테고리 분류 등을 추가하면 실제 앱 수준으로 발전시킬 수 있습니다.

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
