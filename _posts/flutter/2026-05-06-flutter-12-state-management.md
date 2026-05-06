---
title: "[Flutter] 12. 상태관리 - setState, Provider"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter 앱에서 데이터(상태)를 효율적으로 관리하는 방법을 배웁니다.

# 상태관리란?

앱의 데이터(상태)가 변경될 때 UI를 자동으로 업데이트하는 방법입니다.

| 방법 | 난이도 | 적합한 규모 |
|:---:|:---:|:---:|
| setState | 쉬움 | 단일 위젯 |
| Provider | 보통 | 중소규모 앱 |
| Riverpod | 보통 | 중대규모 앱 |
| Bloc | 어려움 | 대규모 앱 |

---

# setState (기본)

단일 위젯 내에서 상태를 관리합니다.

```dart
class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<String> _items = [];
  int _totalPrice = 0;

  void _addItem(String item, int price) {
    setState(() {
      _items.add(item);
      _totalPrice += price;
    });
  }

  void _clearCart() {
    setState(() {
      _items.clear();
      _totalPrice = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('장바구니 (${_items.length})')),
      body: Column(
        children: [
          // 상품 목록
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_items[index]));
              },
            ),
          ),
          // 합계
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('합계: $_totalPrice원',
                style: const TextStyle(fontSize: 20)),
          ),
          // 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _addItem('커피', 4500),
                child: const Text('커피 추가'),
              ),
              ElevatedButton(
                onPressed: () => _addItem('케이크', 6000),
                child: const Text('케이크 추가'),
              ),
              TextButton(
                onPressed: _clearCart,
                child: const Text('비우기'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

### setState의 한계

- 부모 → 자식으로만 데이터 전달 가능
- 깊은 위젯 트리에서 데이터 전달이 복잡해짐
- 관련 없는 위젯까지 리빌드될 수 있음

---

# Provider (권장)

Flutter 팀이 권장하는 상태관리 패키지입니다.

## 설치

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.0.0
```

```bash
flutter pub get
```

## Provider 기본 사용법

### 1. 모델 클래스 생성

```dart
import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<String> _items = [];
  int _totalPrice = 0;

  List<String> get items => _items;
  int get totalPrice => _totalPrice;
  int get itemCount => _items.length;

  void addItem(String item, int price) {
    _items.add(item);
    _totalPrice += price;
    notifyListeners(); // UI 업데이트 알림!
  }

  void removeItem(int index, int price) {
    _items.removeAt(index);
    _totalPrice -= price;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _totalPrice = 0;
    notifyListeners();
  }
}
```

### 2. Provider 등록

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Provider 등록 (앱 최상위)
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ShoppingPage(),
    );
  }
}
```

### 3. Provider 사용 (데이터 읽기)

```dart
class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼핑'),
        actions: [
          // Consumer: 특정 부분만 리빌드
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Badge(
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_cart),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 상품 목록
          _buildProductItem(context, '아메리카노', 4500),
          _buildProductItem(context, '카페라떼', 5000),
          _buildProductItem(context, '치즈케이크', 6500),
          _buildProductItem(context, '크로와상', 3500),

          const Divider(),

          // 장바구니 내용
          Expanded(
            child: Consumer<CartModel>(
              builder: (context, cart, child) {
                return ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cart.items[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cart.removeItem(index, 0),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 합계
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '합계: ${cart.totalPrice}원',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, String name, int price) {
    return ListTile(
      title: Text(name),
      subtitle: Text('${price}원'),
      trailing: ElevatedButton(
        onPressed: () {
          // context.read: 데이터 쓰기 (리빌드 안 함)
          context.read<CartModel>().addItem(name, price);
        },
        child: const Text('담기'),
      ),
    );
  }
}
```

## Provider 읽기 방법 비교

| 방법 | 용도 | 리빌드 |
|:---:|:---:|:---:|
| `context.watch<T>()` | build 안에서 읽기 | 변경 시 리빌드 |
| `context.read<T>()` | 이벤트 핸들러에서 읽기 | 리빌드 안 함 |
| `Consumer<T>` | 특정 위젯만 리빌드 | 해당 부분만 |

```dart
// build 안에서 (UI에 표시)
final cart = context.watch<CartModel>();
Text('${cart.itemCount}개');

// 버튼 클릭 등 이벤트에서
onPressed: () {
  context.read<CartModel>().addItem('커피', 4500);
}
```

---

# 여러 Provider 사용

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const MyApp(),
    ),
  );
}
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
