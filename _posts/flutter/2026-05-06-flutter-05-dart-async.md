---
title: "[Flutter] 05. Dart 비동기 - Future, async/await, Stream"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter에서 네트워크 통신, 파일 읽기 등에 필수적인 비동기 프로그래밍을 배웁니다.

# 비동기 프로그래밍이란?

시간이 걸리는 작업(API 호출, 파일 읽기 등)을 기다리는 동안 다른 작업을 수행하는 방식입니다.

| 동기 | 비동기 |
|:---:|:---:|
| 순서대로 실행 | 동시에 실행 가능 |
| 앞 작업 끝나야 다음 실행 | 기다리지 않고 다음 실행 |
| UI 멈춤 발생 | UI 멈춤 없음 |

---

# Future

## Future 기본

`Future`는 미래에 완료될 값을 나타냅니다.

```dart
// Future를 반환하는 함수
Future<String> fetchData() {
  // 2초 후에 데이터 반환 (네트워크 요청 시뮬레이션)
  return Future.delayed(
    Duration(seconds: 2),
    () => '서버에서 받은 데이터',
  );
}

void main() {
  print('요청 시작');
  fetchData().then((data) {
    print('받은 데이터: $data');
  });
  print('다른 작업 수행');
}
// 출력 순서:
// 요청 시작
// 다른 작업 수행
// 받은 데이터: 서버에서 받은 데이터 (2초 후)
```

## async / await

`then` 대신 더 읽기 쉬운 방식:

```dart
Future<String> fetchUser() async {
  await Future.delayed(Duration(seconds: 1));
  return '홍길동';
}

Future<int> fetchAge(String name) async {
  await Future.delayed(Duration(seconds: 1));
  return 25;
}

// async 함수는 반드시 Future를 반환
Future<void> main() async {
  print('시작');

  // await: Future가 완료될 때까지 대기
  String user = await fetchUser();
  print('사용자: $user');

  int age = await fetchAge(user);
  print('나이: $age');

  print('완료');
}
// 출력:
// 시작
// 사용자: 홍길동 (1초 후)
// 나이: 25 (2초 후)
// 완료
```

## 에러 처리

```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 1));
  throw Exception('네트워크 오류 발생!');
}

Future<void> main() async {
  // try-catch로 에러 처리
  try {
    String data = await fetchData();
    print(data);
  } catch (e) {
    print('에러: $e');
  } finally {
    print('항상 실행됨');
  }
}
```

## 병렬 실행 (Future.wait)

```dart
Future<String> fetchName() async {
  await Future.delayed(Duration(seconds: 2));
  return '홍길동';
}

Future<int> fetchScore() async {
  await Future.delayed(Duration(seconds: 3));
  return 95;
}

Future<void> main() async {
  // 순차 실행: 5초 소요
  // var name = await fetchName();
  // var score = await fetchScore();

  // 병렬 실행: 3초 소요 (더 빠름!)
  var results = await Future.wait([fetchName(), fetchScore()]);
  print('이름: ${results[0]}, 점수: ${results[1]}');
}
```

---

# Stream

## Stream 기본

`Future`는 단일 값, `Stream`은 연속된 값을 전달합니다.

```dart
// Stream 생성
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // 값을 하나씩 전달
  }
}

Future<void> main() async {
  // await for로 Stream 수신
  await for (int value in countStream(5)) {
    print('받은 값: $value');
  }
  print('스트림 완료');
}
// 1초 간격으로 1, 2, 3, 4, 5 출력
```

## StreamController

```dart
import 'dart:async';

void main() {
  // StreamController 생성
  final controller = StreamController<String>();

  // 리스너 등록
  controller.stream.listen(
    (data) => print('수신: $data'),
    onError: (error) => print('에러: $error'),
    onDone: () => print('스트림 종료'),
  );

  // 데이터 전송
  controller.sink.add('첫 번째 메시지');
  controller.sink.add('두 번째 메시지');
  controller.sink.add('세 번째 메시지');

  // 스트림 종료
  controller.close();
}
```

## Stream 변환

```dart
import 'dart:async';

void main() {
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

  // where: 필터링
  // map: 변환
  numbers
      .where((n) => n % 2 == 0)
      .map((n) => n * 10)
      .listen((data) => print(data));
  // 20, 40, 60, 80, 100
}
```

---

# 실습 예제

## API 호출 시뮬레이션

```dart
// 가상 API 서비스
class ApiService {
  Future<Map<String, dynamic>> getUser(int id) async {
    await Future.delayed(Duration(seconds: 1));
    return {'id': id, 'name': '사용자$id', 'email': 'user$id@test.com'};
  }

  Future<List<String>> getPosts(int userId) async {
    await Future.delayed(Duration(seconds: 1));
    return ['게시글1', '게시글2', '게시글3'];
  }
}

Future<void> main() async {
  var api = ApiService();

  try {
    // 사용자 정보 가져오기
    var user = await api.getUser(1);
    print('사용자: ${user['name']}');

    // 해당 사용자의 게시글 가져오기
    var posts = await api.getPosts(user['id']);
    print('게시글 수: ${posts.length}');
    posts.forEach((post) => print('  - $post'));
  } catch (e) {
    print('오류 발생: $e');
  }
}
```

> Flutter에서는 `http` 패키지로 실제 API를 호출하며, 동일한 async/await 패턴을 사용합니다.

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
