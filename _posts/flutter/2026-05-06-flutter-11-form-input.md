---
title: "[Flutter] 11. 사용자 입력 - Form, TextField, 버튼"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

사용자 입력을 받고 처리하는 Form과 다양한 입력 위젯을 배웁니다.

# TextField

## 기본 TextField

```dart
class InputExample extends StatefulWidget {
  const InputExample({super.key});

  @override
  State<InputExample> createState() => _InputExampleState();
}

class _InputExampleState extends State<InputExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // 메모리 해제 필수!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: '이름',
            hintText: '이름을 입력하세요',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            print('입력값: ${_controller.text}');
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
```

## TextField 옵션

```dart
// 비밀번호 입력
TextField(
  obscureText: true,
  decoration: const InputDecoration(
    labelText: '비밀번호',
    prefixIcon: Icon(Icons.lock),
  ),
)

// 숫자만 입력
TextField(
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: '나이'),
)

// 여러 줄 입력
TextField(
  maxLines: 5,
  decoration: const InputDecoration(
    labelText: '메모',
    alignLabelWithHint: true,
    border: OutlineInputBorder(),
  ),
)

// 글자 수 제한
TextField(
  maxLength: 20,
  decoration: const InputDecoration(labelText: '닉네임'),
)
```

---

# Form과 유효성 검사

## Form + TextFormField

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 이메일
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '이메일',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null; // 유효함
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),

              // 비밀번호
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요';
                  }
                  if (value.length < 6) {
                    return '6자 이상 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 24),

              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('로그인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('이메일: $_email, 비밀번호: $_password');
      // 로그인 처리
    }
  }
}
```

---

# 다양한 입력 위젯

## 체크박스 / 스위치

```dart
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 스위치
        SwitchListTile(
          title: const Text('다크 모드'),
          subtitle: const Text('어두운 테마를 사용합니다'),
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
          },
        ),
        // 체크박스
        CheckboxListTile(
          title: const Text('알림 받기'),
          value: _notifications,
          onChanged: (value) {
            setState(() => _notifications = value!);
          },
        ),
      ],
    );
  }
}
```

## 라디오 버튼

```dart
class GenderSelect extends StatefulWidget {
  const GenderSelect({super.key});

  @override
  State<GenderSelect> createState() => _GenderSelectState();
}

class _GenderSelectState extends State<GenderSelect> {
  String _gender = '남성';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('남성'),
          value: '남성',
          groupValue: _gender,
          onChanged: (value) => setState(() => _gender = value!),
        ),
        RadioListTile<String>(
          title: const Text('여성'),
          value: '여성',
          groupValue: _gender,
          onChanged: (value) => setState(() => _gender = value!),
        ),
      ],
    );
  }
}
```

## 드롭다운

```dart
class CityDropdown extends StatefulWidget {
  const CityDropdown({super.key});

  @override
  State<CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown> {
  String _selectedCity = '서울';
  final List<String> _cities = ['서울', '부산', '대구', '인천', '광주'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedCity,
      items: _cities.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCity = value!);
      },
    );
  }
}
```

---

# 버튼 종류

```dart
Column(
  children: [
    // 기본 버튼 (배경색 있음)
    ElevatedButton(
      onPressed: () {},
      child: const Text('ElevatedButton'),
    ),

    // 텍스트 버튼 (배경 없음)
    TextButton(
      onPressed: () {},
      child: const Text('TextButton'),
    ),

    // 외곽선 버튼
    OutlinedButton(
      onPressed: () {},
      child: const Text('OutlinedButton'),
    ),

    // 아이콘 버튼
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.favorite),
    ),

    // 아이콘 + 텍스트
    ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.send),
      label: const Text('전송'),
    ),
  ],
)
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
