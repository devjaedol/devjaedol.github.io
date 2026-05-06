---
title: "[Kotlin] 08. 코루틴 - 비동기 프로그래밍"
categories: 
    - kotlin
tags: 
    [kotlin, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 코루틴(Coroutine)으로 비동기 프로그래밍을 배웁니다.

# 코루틴이란?

코루틴은 경량 스레드로, 비동기 코드를 동기 코드처럼 작성할 수 있게 해줍니다.

| 항목 | 스레드 | 코루틴 |
|:---:|:---:|:---:|
| 비용 | 무거움 (MB 단위 메모리) | 가벼움 (KB 단위) |
| 전환 | OS 레벨 컨텍스트 스위칭 | 사용자 레벨 |
| 수량 | 수천 개 한계 | 수십만 개 가능 |
| 취소 | 복잡 | 간단 (구조화된 동시성) |

---

# 설정

## Gradle 의존성

```kotlin
// build.gradle.kts
dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    // Android인 경우 추가
    // implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

---

# 기본 사용법

## launch와 runBlocking

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {  // 코루틴 스코프 생성
    println("시작: ${Thread.currentThread().name}")

    // launch: 새 코루틴 시작 (결과 반환 안 함)
    launch {
        delay(1000)  // 1초 대기 (스레드 차단 안 함)
        println("코루틴 1 완료")
    }

    launch {
        delay(500)
        println("코루틴 2 완료")
    }

    println("코루틴 시작됨")
}
// 출력:
// 시작: main
// 코루틴 시작됨
// 코루틴 2 완료 (0.5초 후)
// 코루틴 1 완료 (1초 후)
```

## suspend 함수

```kotlin
import kotlinx.coroutines.*

// suspend: 코루틴 안에서만 호출 가능
suspend fun fetchUser(): String {
    delay(1000)  // 네트워크 요청 시뮬레이션
    return "홍길동"
}

suspend fun fetchAge(): Int {
    delay(1000)
    return 25
}

fun main() = runBlocking {
    println("데이터 로딩...")

    val name = fetchUser()
    val age = fetchAge()

    println("$name, $age세")  // 2초 후 출력
}
```

## async / await (결과 반환)

```kotlin
import kotlinx.coroutines.*

suspend fun fetchUser(): String {
    delay(1000)
    return "홍길동"
}

suspend fun fetchScore(): Int {
    delay(1500)
    return 95
}

fun main() = runBlocking {
    // 순차 실행: 2.5초
    // val user = fetchUser()
    // val score = fetchScore()

    // 병렬 실행: 1.5초 (더 빠름!)
    val userDeferred = async { fetchUser() }
    val scoreDeferred = async { fetchScore() }

    val user = userDeferred.await()
    val score = scoreDeferred.await()

    println("$user: ${score}점")
}
```

---

# Dispatcher (실행 스레드 지정)

| Dispatcher | 용도 |
|:---:|:---:|
| Dispatchers.Main | UI 업데이트 (Android) |
| Dispatchers.IO | 네트워크, 파일 I/O |
| Dispatchers.Default | CPU 집약 작업 (계산) |
| Dispatchers.Unconfined | 호출한 스레드에서 시작 |

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    launch(Dispatchers.Default) {
        println("Default: ${Thread.currentThread().name}")
        // CPU 집약 작업
    }

    launch(Dispatchers.IO) {
        println("IO: ${Thread.currentThread().name}")
        // 네트워크/파일 작업
    }

    // withContext: 디스패처 전환
    val result = withContext(Dispatchers.IO) {
        // IO 스레드에서 실행
        delay(1000)
        "데이터 로드 완료"
    }
    println(result)
}
```

---

# 구조화된 동시성

## 코루틴 스코프

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    // coroutineScope: 모든 자식 코루틴이 완료될 때까지 대기
    coroutineScope {
        launch {
            delay(1000)
            println("작업 1 완료")
        }
        launch {
            delay(500)
            println("작업 2 완료")
        }
    }
    println("모든 작업 완료")  // 1초 후 출력
}
```

## 코루틴 취소

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    val job = launch {
        repeat(100) { i ->
            println("작업 중... $i")
            delay(500)
        }
    }

    delay(2000)       // 2초 대기
    println("취소 요청")
    job.cancel()      // 코루틴 취소
    job.join()        // 취소 완료 대기
    println("취소됨")
}
```

## 타임아웃

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    // withTimeout: 시간 초과 시 예외 발생
    try {
        withTimeout(2000) {
            repeat(10) { i ->
                println("작업 $i")
                delay(500)
            }
        }
    } catch (e: TimeoutCancellationException) {
        println("시간 초과!")
    }

    // withTimeoutOrNull: 시간 초과 시 null 반환
    val result = withTimeoutOrNull(1000) {
        delay(2000)
        "완료"
    }
    println(result)  // null
}
```

---

# Flow (비동기 스트림)

여러 값을 순차적으로 방출하는 비동기 스트림:

```kotlin
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

// Flow 생성
fun numberFlow(): Flow<Int> = flow {
    for (i in 1..5) {
        delay(500)
        emit(i)  // 값 방출
    }
}

fun main() = runBlocking {
    // Flow 수집
    numberFlow().collect { value ->
        println("받은 값: $value")
    }
}
```

## Flow 연산자

```kotlin
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

fun main() = runBlocking {
    val numbers = (1..10).asFlow()

    numbers
        .filter { it % 2 == 0 }       // 짝수만
        .map { it * it }              // 제곱
        .take(3)                      // 3개만
        .collect { println(it) }      // 4, 16, 36
}
```

---

# 실습 예제

## 여러 API 동시 호출

```kotlin
import kotlinx.coroutines.*

data class UserProfile(val name: String, val posts: Int, val followers: Int)

suspend fun fetchName(): String {
    delay(1000)
    return "홍길동"
}

suspend fun fetchPostCount(): Int {
    delay(800)
    return 42
}

suspend fun fetchFollowerCount(): Int {
    delay(1200)
    return 1500
}

fun main() = runBlocking {
    println("프로필 로딩...")
    val startTime = System.currentTimeMillis()

    // 병렬 실행
    val profile = coroutineScope {
        val name = async { fetchName() }
        val posts = async { fetchPostCount() }
        val followers = async { fetchFollowerCount() }

        UserProfile(name.await(), posts.await(), followers.await())
    }

    val elapsed = System.currentTimeMillis() - startTime
    println("$profile (${elapsed}ms)")
    // 약 1200ms (가장 긴 작업 기준)
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
