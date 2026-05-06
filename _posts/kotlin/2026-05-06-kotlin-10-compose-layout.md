---
title: "[Kotlin] 10. Compose 레이아웃과 리스트"
categories: 
    - kotlin
tags: 
    [kotlin, android, compose, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Jetpack Compose에서 레이아웃을 구성하고 리스트를 만드는 방법을 배웁니다.

# LazyColumn (스크롤 리스트)

ListView 대체. 화면에 보이는 아이템만 렌더링합니다.

## 기본 LazyColumn

```kotlin
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

@Composable
fun SimpleList() {
    val items = (1..50).map { "아이템 $it" }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(items) { item ->
            Text(
                text = item,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(12.dp)
            )
        }
    }
}
```

## 데이터 클래스와 함께

```kotlin
data class Contact(val id: Int, val name: String, val phone: String)

@Composable
fun ContactList() {
    val contacts = listOf(
        Contact(1, "홍길동", "010-1111-2222"),
        Contact(2, "김철수", "010-3333-4444"),
        Contact(3, "이영희", "010-5555-6666"),
        Contact(4, "박민수", "010-7777-8888"),
    )

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(8.dp)
    ) {
        items(contacts, key = { it.id }) { contact ->
            ContactItem(contact)
        }
    }
}

@Composable
fun ContactItem(contact: Contact) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 아바타
            Surface(
                modifier = Modifier.size(40.dp),
                shape = CircleShape,
                color = MaterialTheme.colorScheme.primary
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        text = contact.name.first().toString(),
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(modifier = Modifier.width(12.dp))
            // 정보
            Column {
                Text(contact.name, fontWeight = FontWeight.Bold)
                Text(contact.phone, color = Color.Gray, fontSize = 14.sp)
            }
        }
    }
}
```

---

# LazyGrid (그리드)

```kotlin
import androidx.compose.foundation.lazy.grid.*

@Composable
fun PhotoGrid() {
    val photos = (1..20).toList()

    LazyVerticalGrid(
        columns = GridCells.Fixed(3),  // 3열 고정
        contentPadding = PaddingValues(8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(photos) { index ->
            Card(
                modifier = Modifier
                    .aspectRatio(1f)  // 정사각형
                    .fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color(0xFF000000 + index * 0x111111)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("$index", color = Color.White)
                }
            }
        }
    }
}
```

---

# Scaffold (기본 화면 구조)

```kotlin
@Composable
fun MainScreen() {
    var selectedTab by remember { mutableStateOf(0) }

    Scaffold(
        // 상단 바
        topBar = {
            TopAppBar(
                title = { Text("내 앱") },
                actions = {
                    IconButton(onClick = { }) {
                        Icon(Icons.Default.Search, "검색")
                    }
                }
            )
        },
        // 하단 네비게이션
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    icon = { Icon(Icons.Default.Home, "홈") },
                    label = { Text("홈") }
                )
                NavigationBarItem(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    icon = { Icon(Icons.Default.Person, "프로필") },
                    label = { Text("프로필") }
                )
                NavigationBarItem(
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 },
                    icon = { Icon(Icons.Default.Settings, "설정") },
                    label = { Text("설정") }
                )
            }
        },
        // FAB
        floatingActionButton = {
            FloatingActionButton(onClick = { }) {
                Icon(Icons.Default.Add, "추가")
            }
        }
    ) { paddingValues ->
        // 본문 내용
        Box(modifier = Modifier.padding(paddingValues)) {
            when (selectedTab) {
                0 -> Text("홈 화면", modifier = Modifier.padding(16.dp))
                1 -> Text("프로필 화면", modifier = Modifier.padding(16.dp))
                2 -> Text("설정 화면", modifier = Modifier.padding(16.dp))
            }
        }
    }
}
```

---

# Card와 Surface

```kotlin
@Composable
fun CardExample() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        elevation = CardDefaults.cardElevation(4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text("카드 제목", style = MaterialTheme.typography.titleMedium)
            Spacer(modifier = Modifier.height(8.dp))
            Text("카드 내용입니다.", style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(onClick = { }) { Text("취소") }
                TextButton(onClick = { }) { Text("확인") }
            }
        }
    }
}
```

---

# 실습 예제: 쇼핑 목록

```kotlin
data class Product(val id: Int, val name: String, val price: Int, val emoji: String)

@Composable
fun ShoppingList() {
    val products = listOf(
        Product(1, "아메리카노", 4500, "☕"),
        Product(2, "카페라떼", 5000, "🥛"),
        Product(3, "치즈케이크", 6500, "🍰"),
        Product(4, "크로와상", 3500, "🥐"),
        Product(5, "마카롱", 2500, "🍪"),
    )

    var cart by remember { mutableStateOf(listOf<Product>()) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("메뉴 (장바구니: ${cart.size})") }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(products, key = { it.id }) { product ->
                Card(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier
                            .padding(16.dp)
                            .fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(product.emoji, fontSize = 24.sp)
                            Spacer(modifier = Modifier.width(12.dp))
                            Column {
                                Text(product.name, fontWeight = FontWeight.Bold)
                                Text("${product.price}원", color = Color.Gray)
                            }
                        }
                        Button(onClick = { cart = cart + product }) {
                            Text("담기")
                        }
                    }
                }
            }
        }
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
