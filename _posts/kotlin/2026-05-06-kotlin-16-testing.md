---
title: "[Kotlin] 16. 테스트 - JUnit, 단위 테스트"
categories: 
    - kotlin
tags: 
    [kotlin, 테스트, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin에서 단위 테스트를 작성하고 실행하는 방법을 배웁니다.

# 테스트 기본

## 의존성

```kotlin
// build.gradle.kts
dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
}

tasks.test {
    useJUnitPlatform()
}
```

---

# JUnit 5 기본

## 첫 번째 테스트

```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class CalculatorTest {

    @Test
    fun `덧셈 테스트`() {
        val result = Calculator.add(2, 3)
        assertEquals(5, result)
    }

    @Test
    fun `뺄셈 테스트`() {
        val result = Calculator.subtract(10, 3)
        assertEquals(7, result)
    }

    @Test
    fun `0으로 나누면 예외 발생`() {
        assertThrows<ArithmeticException> {
            Calculator.divide(10, 0)
        }
    }
}

// 테스트 대상
object Calculator {
    fun add(a: Int, b: Int) = a + b
    fun subtract(a: Int, b: Int) = a - b
    fun divide(a: Int, b: Int): Int {
        require(b != 0) { "0으로 나눌 수 없습니다" }
        return a / b
    }
}
```

## 주요 Assertion

```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class AssertionExamples {

    @Test
    fun `다양한 검증`() {
        // 값 비교
        assertEquals(4, 2 + 2)
        assertNotEquals(5, 2 + 2)

        // 참/거짓
        assertTrue(10 > 5)
        assertFalse(10 < 5)

        // null 체크
        assertNull(null)
        assertNotNull("hello")

        // 같은 객체 참조
        val list = listOf(1, 2, 3)
        assertSame(list, list)

        // 예외 발생 확인
        val exception = assertThrows<IllegalArgumentException> {
            require(false) { "에러 메시지" }
        }
        assertEquals("에러 메시지", exception.message)
    }
}
```

---

# 테스트 생명주기

```kotlin
import org.junit.jupiter.api.*

class LifecycleTest {

    companion object {
        @JvmStatic
        @BeforeAll
        fun beforeAll() {
            println("모든 테스트 전 1회 실행")
        }

        @JvmStatic
        @AfterAll
        fun afterAll() {
            println("모든 테스트 후 1회 실행")
        }
    }

    @BeforeEach
    fun setUp() {
        println("각 테스트 전 실행")
    }

    @AfterEach
    fun tearDown() {
        println("각 테스트 후 실행")
    }

    @Test
    fun `테스트 1`() {
        println("테스트 1 실행")
    }

    @Test
    fun `테스트 2`() {
        println("테스트 2 실행")
    }
}
```

---

# 실전 테스트 예제

## 서비스 클래스 테스트

```kotlin
// 테스트 대상
class UserService {
    private val users = mutableListOf<User>()

    fun addUser(name: String, email: String): User {
        require(name.isNotBlank()) { "이름은 비어있을 수 없습니다" }
        require(email.contains("@")) { "올바른 이메일 형식이 아닙니다" }
        require(users.none { it.email == email }) { "이미 존재하는 이메일입니다" }

        val user = User(id = users.size + 1, name = name, email = email)
        users.add(user)
        return user
    }

    fun findByEmail(email: String): User? = users.find { it.email == email }
    fun getAll(): List<User> = users.toList()
    fun count(): Int = users.size
}

data class User(val id: Int, val name: String, val email: String)
```

```kotlin
// 테스트
class UserServiceTest {
    private lateinit var service: UserService

    @BeforeEach
    fun setUp() {
        service = UserService()
    }

    @Test
    fun `사용자 추가 성공`() {
        val user = service.addUser("홍길동", "hong@test.com")

        assertEquals("홍길동", user.name)
        assertEquals("hong@test.com", user.email)
        assertEquals(1, service.count())
    }

    @Test
    fun `빈 이름으로 추가하면 예외 발생`() {
        assertThrows<IllegalArgumentException> {
            service.addUser("", "test@test.com")
        }
    }

    @Test
    fun `잘못된 이메일 형식이면 예외 발생`() {
        val exception = assertThrows<IllegalArgumentException> {
            service.addUser("홍길동", "invalid-email")
        }
        assertTrue(exception.message!!.contains("이메일"))
    }

    @Test
    fun `중복 이메일 추가 시 예외 발생`() {
        service.addUser("홍길동", "hong@test.com")

        assertThrows<IllegalArgumentException> {
            service.addUser("김철수", "hong@test.com")
        }
    }

    @Test
    fun `이메일로 사용자 검색`() {
        service.addUser("홍길동", "hong@test.com")
        service.addUser("김철수", "kim@test.com")

        val found = service.findByEmail("hong@test.com")
        assertNotNull(found)
        assertEquals("홍길동", found!!.name)

        val notFound = service.findByEmail("none@test.com")
        assertNull(notFound)
    }
}
```

---

# 코루틴 테스트

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
}
```

```kotlin
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test

class AsyncServiceTest {

    @Test
    fun `비동기 데이터 로드 테스트`() = runTest {
        val service = DataService()
        val result = service.fetchData()

        assertEquals("데이터", result)
    }
}

class DataService {
    suspend fun fetchData(): String {
        // 실제로는 네트워크 호출
        kotlinx.coroutines.delay(1000)
        return "데이터"
    }
}
```

---

# 테스트 실행

```bash
# 전체 테스트 실행
./gradlew test

# 특정 클래스만
./gradlew test --tests "UserServiceTest"

# 특정 메서드만
./gradlew test --tests "UserServiceTest.사용자 추가 성공"
```

| 명령어 | 설명 |
|--------|------|
| `./gradlew test` | 전체 테스트 |
| `./gradlew test --info` | 상세 로그 |
| `./gradlew test --tests "패턴"` | 특정 테스트만 |
| IntelliJ ▶ 버튼 | IDE에서 실행 |

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
