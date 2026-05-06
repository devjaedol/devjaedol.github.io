---
title: "[Flutter] 16. 패키지 활용 - 유용한 패키지 소개"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter 개발에 자주 사용되는 패키지를 소개하고 활용법을 배웁니다.

# 패키지 관리

## 패키지 추가 방법

```bash
# CLI로 추가
flutter pub add 패키지명

# pubspec.yaml에 직접 추가 후
flutter pub get
```

## 패키지 검색

[pub.dev](https://pub.dev){:target="_blank"} 에서 패키지를 검색할 수 있습니다.

---

# 자주 사용하는 패키지

| 패키지 | 용도 |
|--------|------|
| provider | 상태관리 |
| http / dio | HTTP 통신 |
| shared_preferences | 간단한 로컬 저장 |
| sqflite | SQLite DB |
| go_router | 라우팅 |
| intl | 날짜/숫자 포맷 |
| cached_network_image | 이미지 캐싱 |
| flutter_svg | SVG 이미지 |
| url_launcher | URL 열기 |
| image_picker | 카메라/갤러리 |

---

# dio (고급 HTTP 클라이언트)

http 패키지보다 기능이 풍부합니다.

```yaml
dependencies:
  dio: ^5.3.0
```

```dart
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ));

    // 인터셉터 (로깅, 토큰 추가 등)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('요청: ${options.method} ${options.path}');
        // 토큰 추가
        options.headers['Authorization'] = 'Bearer token123';
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('응답: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('에러: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Future<List<dynamic>> getUsers() async {
    final response = await _dio.get('/users');
    return response.data;
  }

  Future<dynamic> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post('/users', data: data);
    return response.data;
  }
}
```

---

# go_router (선언적 라우팅)

```yaml
dependencies:
  go_router: ^12.0.0
```

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailPage(id: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

// 사용
void main() {
  runApp(MaterialApp.router(routerConfig: router));
}

// 이동
context.go('/detail/42');
context.push('/settings');
context.pop();
```

---

# intl (날짜/숫자 포맷)

```yaml
dependencies:
  intl: ^0.18.0
```

```dart
import 'package:intl/intl.dart';

void main() {
  // 날짜 포맷
  final now = DateTime.now();
  print(DateFormat('yyyy-MM-dd').format(now));       // 2026-05-06
  print(DateFormat('yyyy년 MM월 dd일').format(now));  // 2026년 05월 06일
  print(DateFormat('HH:mm:ss').format(now));         // 14:30:25
  print(DateFormat.yMMMd('ko').format(now));         // 2026. 5. 6.

  // 숫자 포맷
  print(NumberFormat('#,###').format(1234567));      // 1,234,567
  print(NumberFormat.currency(locale: 'ko', symbol: '₩').format(50000));
  // ₩50,000
}
```

---

# cached_network_image (이미지 캐싱)

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)
```

---

# url_launcher (URL 열기)

```yaml
dependencies:
  url_launcher: ^6.2.0
```

```dart
import 'package:url_launcher/url_launcher.dart';

// 웹 브라우저 열기
Future<void> openUrl() async {
  final uri = Uri.parse('https://flutter.dev');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// 전화 걸기
Future<void> makeCall() async {
  final uri = Uri.parse('tel:010-1234-5678');
  await launchUrl(uri);
}

// 이메일 보내기
Future<void> sendEmail() async {
  final uri = Uri.parse('mailto:test@example.com?subject=제목&body=내용');
  await launchUrl(uri);
}
```

---

# image_picker (카메라/갤러리)

```yaml
dependencies:
  image_picker: ^1.0.0
```

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerExample extends StatefulWidget {
  const ImagePickerExample({super.key});

  @override
  State<ImagePickerExample> createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null) Image.file(_image!, height: 200),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('카메라'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('갤러리'),
            ),
          ],
        ),
      ],
    );
  }
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
