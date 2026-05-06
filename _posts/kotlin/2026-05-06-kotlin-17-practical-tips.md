---
title: "[Kotlin] 17. 실전 팁 - 자주 쓰는 패턴과 관용구"
categories: 
    - kotlin
tags: 
    [kotlin, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

실무에서 자주 사용하는 Kotlin 패턴과 관용구(idiom)를 정리합니다.

# 자주 쓰는 패턴

## 문자열 처리

```kotlin
fun main() {
    val text = "  Hello, Kotlin World!  "

    // 공백 제거 + 분리
    val words = text.trim().split(" ")
    println(words)  // [Hello,, Kotlin, World!]

    // 빈 문자열 체크
    val name = ""
    println(name.isEmpty())      // true
    println(name.isBlank())      // true (공백만 있어도 true)
    println(name.ifEmpty { "기본값" })   // 기본값
    println(name.ifBlank { "기본값" })   // 기본값

    // 정규식
    val email = "user@example.com"
    val isValid = email.matches(Regex("[a-zA-Z0-9.]+@[a-zA-Z0-9]+\\.[a-zA-Z]+"))
    println(isValid)  // true

    // 문자열 빌더
    val result = buildString {
        appendLine("첫 번째 줄")
        appendLine("두 번째 줄")
        append("마지막 줄")
    }
    println(result)
}
```

## 컬렉션 생성 패턴

```kotlin
fun main() {
    // buildList (읽기 전용 리스트를 조건부로 생성)
    val items = buildList {
        add("필수 항목")
        if (true) add("조건부 항목")
        addAll(listOf("추가1", "추가2"))
    }

    // associate (리스트 → 맵 변환)
    val users = listOf("홍길동", "김철수", "이영희")
    val userMap = users.associateWith { it.length }
    println(userMap)  // {홍길동=3, 김철수=3, 이영희=3}

    // groupBy
    val numbers = listOf(1, 2, 3, 4, 5, 6)
    val grouped = numbers.groupBy { if (it % 2 == 0) "짝수" else "홀수" }
    println(grouped)  // {홀수=[1, 3, 5], 짝수=[2, 4, 6]}

    // zip (두 리스트 결합)
    val names = listOf("홍길동", "김철수")
    val ages = listOf(25, 30)
    val pairs = names.zip(ages)
    println(pairs)  // [(홍길동, 25), (김철수, 30)]
}
```

---

## 안전한 타입 변환

```kotlin
fun processInput(input: Any) {
    when (input) {
        is String -> println("문자열: ${input.uppercase()}")
        is Int -> println("정수: ${input * 2}")
        is List<*> -> println("리스트: ${input.size}개")
        else -> println("알 수 없는 타입")
    }
}

// 안전한 캐스팅
fun safeCast(value: Any): String {
    return (value as? String) ?: "변환 실패"
}
```

## 위임 (Delegation)

```kotlin
// by lazy: 최초 접근 시 초기화
class Config {
    val databaseUrl: String by lazy {
        println("DB URL 로딩...")
        "jdbc:mysql://localhost:3306/mydb"
    }
}

// observable: 값 변경 감지
import kotlin.properties.Delegates

class User {
    var name: String by Delegates.observable("초기값") { _, old, new ->
        println("$old → $new 변경됨")
    }

    var age: Int by Delegates.vetoable(0) { _, _, new ->
        new >= 0  // false 반환 시 변경 거부
    }
}

fun main() {
    val config = Config()
    println(config.databaseUrl)  // "DB URL 로딩..." 출력 후 URL 반환
    println(config.databaseUrl)  // 캐시된 값 반환 (로딩 안 함)

    val user = User()
    user.name = "홍길동"  // 초기값 → 홍길동 변경됨
    user.age = -5         // 거부됨 (age는 0 유지)
}
```

---

## 제네릭 활용

```kotlin
// 제네릭 함수
fun <T> List<T>.secondOrNull(): T? {
    return if (size >= 2) this[1] else null
}

// 제네릭 클래스
class Result<out T>(
    val data: T?,
    val error: String?
) {
    val isSuccess: Boolean get() = data != null

    companion object {
        fun <T> success(data: T) = Result(data, null)
        fun <T> failure(error: String) = Result<T>(null, error)
    }
}

fun main() {
    val numbers = listOf(10, 20, 30)
    println(numbers.secondOrNull())  // 20

    val result = Result.success("데이터")
    if (result.isSuccess) {
        println(result.data)
    }
}
```

---

## DSL 스타일 빌더

```kotlin
// HTML DSL 예시
class HtmlBuilder {
    private val elements = mutableListOf<String>()

    fun h1(text: String) { elements.add("<h1>$text</h1>") }
    fun p(text: String) { elements.add("<p>$text</p>") }
    fun ul(block: UlBuilder.() -> Unit) {
        val ul = UlBuilder()
        ul.block()
        elements.add(ul.build())
    }

    fun build() = elements.joinToString("\n")
}

class UlBuilder {
    private val items = mutableListOf<String>()
    fun li(text: String) { items.add("<li>$text</li>") }
    fun build() = "<ul>\n${items.joinToString("\n")}\n</ul>"
}

fun html(block: HtmlBuilder.() -> Unit): String {
    val builder = HtmlBuilder()
    builder.block()
    return builder.build()
}

fun main() {
    val page = html {
        h1("Kotlin DSL")
        p("DSL로 HTML을 생성합니다")
        ul {
            li("항목 1")
            li("항목 2")
            li("항목 3")
        }
    }
    println(page)
}
```

---

## 유용한 표준 라이브러리 함수

```kotlin
fun main() {
    // repeat: N번 반복
    repeat(3) { println("반복 $it") }

    // takeIf / takeUnless
    val number = 42
    val even = number.takeIf { it % 2 == 0 }  // 42 (조건 만족)
    val odd = number.takeUnless { it % 2 == 0 }  // null (조건 불만족)

    // use: 자동 리소스 해제 (try-with-resources)
    java.io.File("test.txt").bufferedReader().use { reader ->
        println(reader.readLine())
    }

    // measureTimeMillis: 실행 시간 측정
    val time = kotlin.system.measureTimeMillis {
        Thread.sleep(100)
    }
    println("실행 시간: ${time}ms")

    // runCatching: 안전한 실행
    val result = runCatching {
        "abc".toInt()
    }.getOrDefault(0)
    println(result)  // 0
}
```

---

# Java → Kotlin 변환 팁

| Java | Kotlin |
|------|--------|
| `new ArrayList<>()` | `mutableListOf()` |
| `String.format("%s", x)` | `"$x"` 또는 `"${expr}"` |
| `obj instanceof Type` | `obj is Type` |
| `(Type) obj` | `obj as Type` |
| `obj != null ? obj.method() : null` | `obj?.method()` |
| `Collections.unmodifiableList(list)` | `list.toList()` |
| `try { } finally { close() }` | `.use { }` |
| getter/setter | `val` / `var` (자동 생성) |

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
