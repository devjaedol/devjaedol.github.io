---
title: "[Kotlin] 12. 상태관리 - ViewModel, State"
categories: 
    - kotlin
tags: 
    [kotlin, android, compose, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Android 앱에서 데이터를 효율적으로 관리하는 ViewModel과 상태 관리를 배웁니다.

# ViewModel이란?

화면 회전 등 구성 변경에도 데이터를 유지하는 컴포넌트입니다.

| 항목 | remember | ViewModel |
|:---:|:---:|:---:|
| 생존 범위 | Composable | Activity/Fragment |
| 화면 회전 | 데이터 소실 | 데이터 유지 |
| 용도 | UI 상태 | 비즈니스 로직 + 데이터 |

## 의존성

```kotlin
// build.gradle.kts
dependencies {
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.6.0")
}
```

---

# ViewModel 기본

## 카운터 예제

```kotlin
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class CounterViewModel : ViewModel() {
    private val _count = MutableStateFlow(0)
    val count: StateFlow<Int> = _count.asStateFlow()

    fun increment() {
        _count.value++
    }

    fun decrement() {
        _count.value--
    }

    fun reset() {
        _count.value = 0
    }
}
```

## Composable에서 사용

```kotlin
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.compose.runtime.collectAsState

@Composable
fun CounterScreen(viewModel: CounterViewModel = viewModel()) {
    val count by viewModel.count.collectAsState()

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("$count", fontSize = 48.sp)
        Spacer(modifier = Modifier.height(16.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = { viewModel.decrement() }) { Text("-") }
            Button(onClick = { viewModel.reset() }) { Text("초기화") }
            Button(onClick = { viewModel.increment() }) { Text("+") }
        }
    }
}
```

---

# Todo 앱 ViewModel

## 모델

```kotlin
data class Todo(
    val id: Int,
    val title: String,
    val isDone: Boolean = false
)
```

## ViewModel

```kotlin
class TodoViewModel : ViewModel() {
    private val _todos = MutableStateFlow<List<Todo>>(emptyList())
    val todos: StateFlow<List<Todo>> = _todos.asStateFlow()

    private var nextId = 1

    val doneCount: Int get() = _todos.value.count { it.isDone }
    val totalCount: Int get() = _todos.value.size

    fun addTodo(title: String) {
        if (title.isBlank()) return
        val newTodo = Todo(id = nextId++, title = title.trim())
        _todos.value = _todos.value + newTodo
    }

    fun toggleTodo(id: Int) {
        _todos.value = _todos.value.map { todo ->
            if (todo.id == id) todo.copy(isDone = !todo.isDone) else todo
        }
    }

    fun deleteTodo(id: Int) {
        _todos.value = _todos.value.filter { it.id != id }
    }
}
```

## UI

```kotlin
@Composable
fun TodoScreen(viewModel: TodoViewModel = viewModel()) {
    val todos by viewModel.todos.collectAsState()
    var inputText by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("할일 (${viewModel.doneCount}/${viewModel.totalCount})") }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            // 입력 영역
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = inputText,
                    onValueChange = { inputText = it },
                    modifier = Modifier.weight(1f),
                    placeholder = { Text("할일 입력") },
                    singleLine = true
                )
                Spacer(modifier = Modifier.width(8.dp))
                Button(onClick = {
                    viewModel.addTodo(inputText)
                    inputText = ""
                }) {
                    Text("추가")
                }
            }

            // 목록
            LazyColumn {
                items(todos, key = { it.id }) { todo ->
                    TodoItem(
                        todo = todo,
                        onToggle = { viewModel.toggleTodo(todo.id) },
                        onDelete = { viewModel.deleteTodo(todo.id) }
                    )
                }
            }
        }
    }
}

@Composable
fun TodoItem(todo: Todo, onToggle: () -> Unit, onDelete: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 4.dp)
    ) {
        Row(
            modifier = Modifier.padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(checked = todo.isDone, onCheckedChange = { onToggle() })
            Text(
                text = todo.title,
                modifier = Modifier.weight(1f),
                style = if (todo.isDone) {
                    TextStyle(textDecoration = TextDecoration.LineThrough, color = Color.Gray)
                } else TextStyle()
            )
            IconButton(onClick = onDelete) {
                Icon(Icons.Default.Delete, "삭제", tint = Color.Red)
            }
        }
    }
}
```

---

# UI State 패턴

## sealed class로 상태 표현

```kotlin
sealed class UiState<out T> {
    object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}

class UserViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<UiState<List<User>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<User>>> = _uiState.asStateFlow()

    init {
        loadUsers()
    }

    private fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val users = repository.getUsers()
                _uiState.value = UiState.Success(users)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "알 수 없는 오류")
            }
        }
    }
}

@Composable
fun UserScreen(viewModel: UserViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsState()

    when (val state = uiState) {
        is UiState.Loading -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        }
        is UiState.Success -> {
            LazyColumn {
                items(state.data) { user ->
                    Text(user.name)
                }
            }
        }
        is UiState.Error -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("에러: ${state.message}", color = Color.Red)
            }
        }
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
