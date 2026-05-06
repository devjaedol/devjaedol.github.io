---
title: "[Kotlin] 13. 네트워크 통신 - Retrofit"
categories: 
    - kotlin
tags: 
    [kotlin, android, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Retrofit을 사용하여 REST API와 통신하는 방법을 배웁니다.

# Retrofit이란?

Android에서 가장 많이 사용되는 HTTP 클라이언트 라이브러리입니다.

## 의존성 추가

```kotlin
// build.gradle.kts (app)
dependencies {
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.11.0")
}
```

## 인터넷 권한

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

---

# 기본 사용법

## 1. 데이터 모델

```kotlin
data class Post(
    val id: Int,
    val userId: Int,
    val title: String,
    val body: String
)

data class User(
    val id: Int,
    val name: String,
    val email: String,
    val phone: String
)
```

## 2. API 인터페이스 정의

```kotlin
import retrofit2.http.*

interface ApiService {
    // GET: 목록 조회
    @GET("posts")
    suspend fun getPosts(): List<Post>

    // GET: 단건 조회 (경로 매개변수)
    @GET("posts/{id}")
    suspend fun getPost(@Path("id") id: Int): Post

    // GET: 쿼리 파라미터
    @GET("posts")
    suspend fun getPostsByUser(@Query("userId") userId: Int): List<Post>

    // POST: 생성
    @POST("posts")
    suspend fun createPost(@Body post: Post): Post

    // PUT: 수정
    @PUT("posts/{id}")
    suspend fun updatePost(@Path("id") id: Int, @Body post: Post): Post

    // DELETE: 삭제
    @DELETE("posts/{id}")
    suspend fun deletePost(@Path("id") id: Int)
}
```

## 3. Retrofit 인스턴스 생성

```kotlin
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor

object RetrofitClient {
    private const val BASE_URL = "https://jsonplaceholder.typicode.com/"

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .build()

    val apiService: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}
```

---

# ViewModel에서 사용

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class PostViewModel : ViewModel() {
    private val _posts = MutableStateFlow<List<Post>>(emptyList())
    val posts: StateFlow<List<Post>> = _posts

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error

    init {
        loadPosts()
    }

    fun loadPosts() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                _posts.value = RetrofitClient.apiService.getPosts()
            } catch (e: Exception) {
                _error.value = e.message ?: "알 수 없는 오류"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun createPost(title: String, body: String) {
        viewModelScope.launch {
            try {
                val newPost = Post(id = 0, userId = 1, title = title, body = body)
                val created = RetrofitClient.apiService.createPost(newPost)
                _posts.value = listOf(created) + _posts.value
            } catch (e: Exception) {
                _error.value = "생성 실패: ${e.message}"
            }
        }
    }
}
```

---

# UI 연결

```kotlin
@Composable
fun PostListScreen(viewModel: PostViewModel = viewModel()) {
    val posts by viewModel.posts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    Scaffold(
        topBar = { TopAppBar(title = { Text("게시글") }) }
    ) { padding ->
        Box(modifier = Modifier.padding(padding).fillMaxSize()) {
            when {
                isLoading -> {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
                error != null -> {
                    Column(
                        modifier = Modifier.align(Alignment.Center),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("오류: $error", color = Color.Red)
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(onClick = { viewModel.loadPosts() }) {
                            Text("다시 시도")
                        }
                    }
                }
                else -> {
                    LazyColumn(contentPadding = PaddingValues(16.dp)) {
                        items(posts, key = { it.id }) { post ->
                            PostItem(post)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun PostItem(post: Post) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = post.title,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = post.body,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                color = Color.Gray
            )
        }
    }
}
```

---

# Repository 패턴

실제 앱에서는 Repository로 데이터 소스를 추상화합니다.

```kotlin
class PostRepository {
    private val api = RetrofitClient.apiService

    suspend fun getPosts(): Result<List<Post>> {
        return try {
            Result.success(api.getPosts())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPost(id: Int): Result<Post> {
        return try {
            Result.success(api.getPost(id))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createPost(title: String, body: String): Result<Post> {
        return try {
            val post = Post(id = 0, userId = 1, title = title, body = body)
            Result.success(api.createPost(post))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

// ViewModel에서 사용
class PostViewModel(
    private val repository: PostRepository = PostRepository()
) : ViewModel() {

    fun loadPosts() {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getPosts()
                .onSuccess { _posts.value = it }
                .onFailure { _error.value = it.message }
            _isLoading.value = false
        }
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
