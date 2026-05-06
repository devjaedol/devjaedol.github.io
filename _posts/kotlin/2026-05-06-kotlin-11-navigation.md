---
title: "[Kotlin] 11. 화면 이동 - Navigation"
categories: 
    - kotlin
tags: 
    [kotlin, android, compose, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Jetpack Compose에서 화면 간 이동(Navigation)을 구현합니다.

# Navigation 설정

## 의존성 추가

```kotlin
// build.gradle.kts (app)
dependencies {
    implementation("androidx.navigation:navigation-compose:2.7.0")
}
```

---

# 기본 Navigation

## NavHost 설정

```kotlin
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

@Composable
fun MyApp() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "home"  // 시작 화면
    ) {
        composable("home") {
            HomeScreen(navController)
        }
        composable("detail") {
            DetailScreen(navController)
        }
        composable("settings") {
            SettingsScreen(navController)
        }
    }
}
```

## 화면 이동

```kotlin
@Composable
fun HomeScreen(navController: NavController) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("홈 화면", fontSize = 24.sp)
        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = {
            navController.navigate("detail")  // 이동
        }) {
            Text("상세 화면으로")
        }

        Button(onClick = {
            navController.navigate("settings")
        }) {
            Text("설정으로")
        }
    }
}

@Composable
fun DetailScreen(navController: NavController) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("상세 화면", fontSize = 24.sp)
        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = {
            navController.popBackStack()  // 뒤로 가기
        }) {
            Text("뒤로 가기")
        }
    }
}
```

---

# 데이터 전달 (Arguments)

## 경로 매개변수

```kotlin
@Composable
fun MyApp() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "list") {
        composable("list") {
            ListScreen(navController)
        }
        // {id}는 경로 매개변수
        composable("detail/{id}") { backStackEntry ->
            val id = backStackEntry.arguments?.getString("id") ?: "0"
            DetailScreen(navController, id)
        }
        // 선택적 매개변수 (쿼리 파라미터)
        composable("search?query={query}") { backStackEntry ->
            val query = backStackEntry.arguments?.getString("query") ?: ""
            SearchScreen(navController, query)
        }
    }
}

@Composable
fun ListScreen(navController: NavController) {
    LazyColumn {
        items(10) { index ->
            TextButton(onClick = {
                navController.navigate("detail/$index")  // id 전달
            }) {
                Text("아이템 $index")
            }
        }
    }
}

@Composable
fun DetailScreen(navController: NavController, id: String) {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("상세 화면 - ID: $id", fontSize = 20.sp)
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { navController.popBackStack() }) {
            Text("뒤로")
        }
    }
}
```

## 타입 안전한 인자

```kotlin
import androidx.navigation.NavType
import androidx.navigation.navArgument

NavHost(navController = navController, startDestination = "list") {
    composable(
        route = "detail/{id}/{title}",
        arguments = listOf(
            navArgument("id") { type = NavType.IntType },
            navArgument("title") { type = NavType.StringType }
        )
    ) { backStackEntry ->
        val id = backStackEntry.arguments?.getInt("id") ?: 0
        val title = backStackEntry.arguments?.getString("title") ?: ""
        DetailScreen(navController, id, title)
    }
}

// 이동
navController.navigate("detail/42/제목입니다")
```

---

# 네비게이션 옵션

## 백스택 관리

```kotlin
// 특정 화면까지 백스택 제거
navController.navigate("home") {
    popUpTo("home") { inclusive = true }  // home까지 제거 후 이동
}

// 중복 방지 (같은 화면 여러 번 쌓이지 않게)
navController.navigate("detail") {
    launchSingleTop = true
}

// 상태 저장/복원
navController.navigate("settings") {
    popUpTo(navController.graph.startDestinationId) {
        saveState = true
    }
    restoreState = true
    launchSingleTop = true
}
```

---

# Bottom Navigation과 연동

```kotlin
@Composable
fun MainScreen() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar {
                val currentRoute = navController
                    .currentBackStackEntryAsState().value?.destination?.route

                NavigationBarItem(
                    selected = currentRoute == "home",
                    onClick = {
                        navController.navigate("home") {
                            popUpTo("home") { inclusive = true }
                            launchSingleTop = true
                        }
                    },
                    icon = { Icon(Icons.Default.Home, "홈") },
                    label = { Text("홈") }
                )
                NavigationBarItem(
                    selected = currentRoute == "search",
                    onClick = {
                        navController.navigate("search") {
                            launchSingleTop = true
                        }
                    },
                    icon = { Icon(Icons.Default.Search, "검색") },
                    label = { Text("검색") }
                )
                NavigationBarItem(
                    selected = currentRoute == "profile",
                    onClick = {
                        navController.navigate("profile") {
                            launchSingleTop = true
                        }
                    },
                    icon = { Icon(Icons.Default.Person, "프로필") },
                    label = { Text("프로필") }
                )
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = "home",
            modifier = Modifier.padding(padding)
        ) {
            composable("home") { HomeScreen(navController) }
            composable("search") { SearchScreen(navController) }
            composable("profile") { ProfileScreen(navController) }
        }
    }
}
```

---

# 실습 예제: 메뉴 앱 네비게이션

```kotlin
data class MenuItem(val id: Int, val name: String, val price: Int, val desc: String)

@Composable
fun MenuApp() {
    val navController = rememberNavController()
    val menuItems = listOf(
        MenuItem(1, "아메리카노", 4500, "깊고 진한 에스프레소"),
        MenuItem(2, "카페라떼", 5000, "부드러운 우유와 에스프레소"),
        MenuItem(3, "카푸치노", 5000, "풍성한 우유 거품"),
    )

    NavHost(navController = navController, startDestination = "menu") {
        composable("menu") {
            MenuListScreen(navController, menuItems)
        }
        composable("detail/{id}",
            arguments = listOf(navArgument("id") { type = NavType.IntType })
        ) { backStackEntry ->
            val id = backStackEntry.arguments?.getInt("id") ?: 0
            val item = menuItems.find { it.id == id }
            item?.let { MenuDetailScreen(navController, it) }
        }
    }
}

@Composable
fun MenuListScreen(navController: NavController, items: List<MenuItem>) {
    Scaffold(topBar = { TopAppBar(title = { Text("메뉴") }) }) { padding ->
        LazyColumn(modifier = Modifier.padding(padding)) {
            items(items, key = { it.id }) { item ->
                ListItem(
                    headlineContent = { Text(item.name) },
                    supportingContent = { Text("${item.price}원") },
                    modifier = Modifier.clickable {
                        navController.navigate("detail/${item.id}")
                    }
                )
            }
        }
    }
}

@Composable
fun MenuDetailScreen(navController: NavController, item: MenuItem) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(item.name) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, "뒤로")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(16.dp)) {
            Text(item.name, fontSize = 24.sp, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            Text(item.desc)
            Spacer(modifier = Modifier.height(16.dp))
            Text("${item.price}원", fontSize = 20.sp, color = Color.Blue)
            Spacer(modifier = Modifier.height(24.dp))
            Button(
                onClick = { /* 주문 처리 */ },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("주문하기")
            }
        }
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
