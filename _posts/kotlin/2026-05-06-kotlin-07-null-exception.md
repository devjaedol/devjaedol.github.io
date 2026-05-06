---
title: "[Kotlin] 07. Null 안전성과 예외 처리"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 Null Safety 시스템과 예외 처리 방법을 배웁니다.

# Null Safety 심화

## nullable 타입 연산자 정리

| 연산자 | 이름 | 설명 |
|:---:|:---:|:---:|
| `?` | nullable 선언 | null 허용 타입 |
| `?.` | 안전 호출 | null이면 null 반환 |
| `?:` | 엘비스 | null이면 기본값 |
| `!!` | non-null 단언 | null이면 예외 발생 |
| `as?` | 안전 캐스팅 | 실패 시 null |

## 안전 호출 체이닝

```kotlin
data class Address(val city: String?, val zipCode: String?)
data class Company(val name: String, val address: Address?)
data class Employee(val name: String, val company: Company?)

fun main() {
    val employee = Employee("홍길동", Company("ABC", Address("서울", "12345")))
    val nullEmployee = Employee("김철수", null)

    // 안전 호출 체이닝
    val city = employee.company?.address?.city
    println(city)  // 서울

    val nullCity = nullEmployee.company?.address?.city
    println(nullCity)  // null (에러 없음)

    // 엘비스 연산자로 기본값
    val displayCity = nullEmployee.company?.address?.city ?: "주소 없음"
    println(displayCity)  // 주소 없음
}
```

## let을 활용한 null 처리

```kotlin
fun main() {
    val name: String? = "Kotlin"
    val nullName: String? = null

    // null이 아닐 때만 실행
    name?.let { value ->
        println("이름: $value")
        println("길이: ${value.length}")
    }

    // null일 때 처리
    nullName?.let {
        println("실행 안 됨")
    } ?: println("이름이 없습니다")

    // 여러 nullable 값 처리
    val firstName: String? = "길동"
    val lastName: String? = "홍"

    if (firstName != null && lastName != null) {
        println("$lastName$firstName")  // 스마트 캐스트
    }
}
```

## 플랫폼 타입 (Java 연동)

```kotlin
// Java 코드에서 온 값은 nullable일 수 있음
// 항상 null 체크를 하는 것이 안전

fun processJavaString(str: String?) {
    // Java에서 온 값은 nullable로 처리
    val length = str?.length ?: 0
    println("길이: $length")
}
```

---

# 예외 처리

## try-catch-finally

```kotlin
fun divide(a: Int, b: Int): Int {
    return try {
        a / b
    } catch (e: ArithmeticException) {
        println("0으로 나눌 수 없습니다: ${e.message}")
        0  // 기본값 반환
    } finally {
        println("나눗셈 시도 완료")  // 항상 실행
    }
}

fun main() {
    println(divide(10, 2))   // 5
    println(divide(10, 0))   // 0 (에러 처리됨)
}
```

## try를 표현식으로 사용

```kotlin
fun main() {
    val input = "abc"

    // try를 표현식으로 (값 반환)
    val number = try {
        input.toInt()
    } catch (e: NumberFormatException) {
        -1  // 변환 실패 시 기본값
    }

    println(number)  // -1
}
```

## 여러 예외 처리

```kotlin
fun readFile(path: String): String {
    return try {
        java.io.File(path).readText()
    } catch (e: java.io.FileNotFoundException) {
        println("파일을 찾을 수 없습니다: $path")
        ""
    } catch (e: java.io.IOException) {
        println("파일 읽기 오류: ${e.message}")
        ""
    } catch (e: Exception) {
        println("알 수 없는 오류: ${e.message}")
        ""
    }
}
```

## 사용자 정의 예외

```kotlin
// 커스텀 예외
class InvalidAgeException(message: String) : Exception(message)
class InsufficientBalanceException(val balance: Double) :
    Exception("잔액 부족: ${balance}원")

fun validateAge(age: Int) {
    if (age < 0 || age > 150) {
        throw InvalidAgeException("유효하지 않은 나이: $age")
    }
}

fun withdraw(balance: Double, amount: Double): Double {
    if (amount > balance) {
        throw InsufficientBalanceException(balance)
    }
    return balance - amount
}

fun main() {
    try {
        validateAge(200)
    } catch (e: InvalidAgeException) {
        println(e.message)  // 유효하지 않은 나이: 200
    }

    try {
        withdraw(1000.0, 5000.0)
    } catch (e: InsufficientBalanceException) {
        println(e.message)  // 잔액 부족: 1000.0원
    }
}
```

---

# require / check / error

Kotlin 표준 라이브러리의 검증 함수:

```kotlin
fun createUser(name: String, age: Int): String {
    // require: 매개변수 검증 (IllegalArgumentException)
    require(name.isNotBlank()) { "이름은 비어있을 수 없습니다" }
    require(age in 1..150) { "나이는 1~150 사이여야 합니다" }

    return "$name ($age세)"
}

class Connection {
    var isConnected = false

    fun sendData(data: String) {
        // check: 상태 검증 (IllegalStateException)
        check(isConnected) { "연결되지 않은 상태입니다" }
        println("전송: $data")
    }
}

fun getConfig(key: String): String {
    val config = mapOf("host" to "localhost", "port" to "3306")
    // error: 도달하면 안 되는 코드 (IllegalStateException)
    return config[key] ?: error("설정을 찾을 수 없습니다: $key")
}

fun main() {
    try {
        createUser("", 25)
    } catch (e: IllegalArgumentException) {
        println(e.message)  // 이름은 비어있을 수 없습니다
    }

    try {
        getConfig("database")
    } catch (e: IllegalStateException) {
        println(e.message)  // 설정을 찾을 수 없습니다: database
    }
}
```

---

# Result 타입 활용

```kotlin
fun parseNumber(input: String): Result<Int> {
    return try {
        Result.success(input.toInt())
    } catch (e: NumberFormatException) {
        Result.failure(e)
    }
}

fun main() {
    val result1 = parseNumber("42")
    val result2 = parseNumber("abc")

    // 성공/실패 처리
    result1.onSuccess { println("성공: $it") }  // 성공: 42
    result1.onFailure { println("실패: ${it.message}") }

    result2.onSuccess { println("성공: $it") }
    result2.onFailure { println("실패: ${it.message}") }  // 실패: For input string: "abc"

    // getOrDefault
    val num = result2.getOrDefault(0)
    println(num)  // 0

    // getOrElse
    val num2 = result2.getOrElse { -1 }
    println(num2)  // -1
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
