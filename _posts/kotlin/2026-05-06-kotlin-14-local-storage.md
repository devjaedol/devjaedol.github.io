---
title: "[Kotlin] 14. 로컬 저장소 - Room, DataStore"
categories: 
    - kotlin
tags: 
    [kotlin, android, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Android에서 데이터를 로컬에 저장하는 Room DB와 DataStore를 배웁니다.

# 저장 방식 비교

| 방식 | 용도 | 특징 |
|:---:|:---:|:---:|
| DataStore | 설정값, 간단한 데이터 | key-value, 비동기 |
| Room | 구조화된 데이터 | SQLite 래퍼, ORM |
| SharedPreferences | 레거시 설정값 | 동기, 비권장 |

---

# DataStore (설정 저장)

SharedPreferences의 현대적 대체입니다.

## 의존성

```kotlin
// build.gradle.kts
dependencies {
    implementation("androidx.datastore:datastore-preferences:1.0.0")
}
```

## 사용법

```kotlin
import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

// DataStore 인스턴스
val Context.dataStore by preferencesDataStore(name = "settings")

// 키 정의
object PrefsKeys {
    val DARK_MODE = booleanPreferencesKey("dark_mode")
    val USERNAME = stringPreferencesKey("username")
    val FONT_SIZE = intPreferencesKey("font_size")
}

class SettingsRepository(private val context: Context) {
    // 읽기 (Flow로 반환)
    val darkMode: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[PrefsKeys.DARK_MODE] ?: false
    }

    val username: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[PrefsKeys.USERNAME] ?: ""
    }

    // 저장
    suspend fun setDarkMode(enabled: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[PrefsKeys.DARK_MODE] = enabled
        }
    }

    suspend fun setUsername(name: String) {
        context.dataStore.edit { prefs ->
            prefs[PrefsKeys.USERNAME] = name
        }
    }

    // 삭제
    suspend fun clearAll() {
        context.dataStore.edit { it.clear() }
    }
}
```

## ViewModel에서 사용

```kotlin
class SettingsViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = SettingsRepository(application)

    val darkMode = repository.darkMode
    val username = repository.username

    fun toggleDarkMode(enabled: Boolean) {
        viewModelScope.launch {
            repository.setDarkMode(enabled)
        }
    }

    fun updateUsername(name: String) {
        viewModelScope.launch {
            repository.setUsername(name)
        }
    }
}

@Composable
fun SettingsScreen(viewModel: SettingsViewModel = viewModel()) {
    val darkMode by viewModel.darkMode.collectAsState(initial = false)
    val username by viewModel.username.collectAsState(initial = "")

    Column(modifier = Modifier.padding(16.dp)) {
        SwitchListTile(
            checked = darkMode,
            onCheckedChange = { viewModel.toggleDarkMode(it) },
            title = "다크 모드"
        )
        OutlinedTextField(
            value = username,
            onValueChange = { viewModel.updateUsername(it) },
            label = { Text("사용자 이름") }
        )
    }
}
```

---

# Room (SQLite ORM)

## 의존성

```kotlin
// build.gradle.kts
plugins {
    id("com.google.devtools.ksp") version "1.9.0-1.0.13"
}

dependencies {
    implementation("androidx.room:room-runtime:2.6.0")
    implementation("androidx.room:room-ktx:2.6.0")  // 코루틴 지원
    ksp("androidx.room:room-compiler:2.6.0")
}
```

## 1. Entity (테이블)

```kotlin
import androidx.room.*

@Entity(tableName = "memos")
data class Memo(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val title: String,
    val content: String,
    val createdAt: Long = System.currentTimeMillis(),
    val isDone: Boolean = false
)
```

## 2. DAO (데이터 접근 객체)

```kotlin
@Dao
interface MemoDao {
    // 전체 조회 (Flow로 실시간 업데이트)
    @Query("SELECT * FROM memos ORDER BY createdAt DESC")
    fun getAll(): Flow<List<Memo>>

    // 단건 조회
    @Query("SELECT * FROM memos WHERE id = :id")
    suspend fun getById(id: Int): Memo?

    // 검색
    @Query("SELECT * FROM memos WHERE title LIKE '%' || :keyword || '%'")
    fun search(keyword: String): Flow<List<Memo>>

    // 삽입
    @Insert
    suspend fun insert(memo: Memo)

    // 수정
    @Update
    suspend fun update(memo: Memo)

    // 삭제
    @Delete
    suspend fun delete(memo: Memo)

    // ID로 삭제
    @Query("DELETE FROM memos WHERE id = :id")
    suspend fun deleteById(id: Int)

    // 전체 삭제
    @Query("DELETE FROM memos")
    suspend fun deleteAll()
}
```

## 3. Database

```kotlin
@Database(entities = [Memo::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun memoDao(): MemoDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database"
                ).build().also { INSTANCE = it }
            }
        }
    }
}
```

## 4. Repository

```kotlin
class MemoRepository(private val memoDao: MemoDao) {
    val allMemos: Flow<List<Memo>> = memoDao.getAll()

    suspend fun insert(title: String, content: String) {
        memoDao.insert(Memo(title = title, content = content))
    }

    suspend fun update(memo: Memo) {
        memoDao.update(memo)
    }

    suspend fun delete(memo: Memo) {
        memoDao.delete(memo)
    }

    fun search(keyword: String): Flow<List<Memo>> {
        return memoDao.search(keyword)
    }
}
```

## 5. ViewModel

```kotlin
class MemoViewModel(application: Application) : AndroidViewModel(application) {
    private val repository: MemoRepository

    val allMemos: StateFlow<List<Memo>>

    init {
        val dao = AppDatabase.getDatabase(application).memoDao()
        repository = MemoRepository(dao)
        allMemos = repository.allMemos
            .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())
    }

    fun addMemo(title: String, content: String) {
        viewModelScope.launch {
            repository.insert(title, content)
        }
    }

    fun deleteMemo(memo: Memo) {
        viewModelScope.launch {
            repository.delete(memo)
        }
    }

    fun toggleDone(memo: Memo) {
        viewModelScope.launch {
            repository.update(memo.copy(isDone = !memo.isDone))
        }
    }
}
```

## 6. UI

```kotlin
@Composable
fun MemoScreen(viewModel: MemoViewModel = viewModel()) {
    val memos by viewModel.allMemos.collectAsState()
    var showDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = { TopAppBar(title = { Text("메모 (${memos.size})") }) },
        floatingActionButton = {
            FloatingActionButton(onClick = { showDialog = true }) {
                Icon(Icons.Default.Add, "추가")
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.padding(padding),
            contentPadding = PaddingValues(16.dp)
        ) {
            items(memos, key = { it.id }) { memo ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = memo.isDone,
                            onCheckedChange = { viewModel.toggleDone(memo) }
                        )
                        Column(modifier = Modifier.weight(1f)) {
                            Text(memo.title, fontWeight = FontWeight.Bold)
                            Text(memo.content, color = Color.Gray, maxLines = 1)
                        }
                        IconButton(onClick = { viewModel.deleteMemo(memo) }) {
                            Icon(Icons.Default.Delete, "삭제")
                        }
                    }
                }
            }
        }
    }

    if (showDialog) {
        AddMemoDialog(
            onDismiss = { showDialog = false },
            onConfirm = { title, content ->
                viewModel.addMemo(title, content)
                showDialog = false
            }
        )
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
