---
title: "[Kotlin] 04. 함수 - 선언, 매개변수, 람다"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 함수 선언과 다양한 활용법을 배웁니다.

# 함수 기본

## 함수 선언

```kotlin
// 기본 형태
fun 함수명(매개변수: 타입): 반환타입 {
    return 값
}
```

```kotlin
fun add(a: Int, b: Int): Int {
    return a + b
}

fun greet(name: String): String {
    return "안녕하세요, ${name}님!"
}

// 반환값 없음 (Unit = Java의 void)
fun printMessage(msg: String) {
    println(msg)
}

fun main() {
    println(add(3, 5))       // 8
    println(greet("홍길동"))  // 안녕하세요, 홍길동님!
    printMessage("Hello")    // Hello
}
```

## 단일 표현식 함수

한 줄로 표현 가능한 함수:

```kotlin
fun add(a: Int, b: Int): Int = a + b
fun greet(name: String) = "Hello, $name!"  // 반환 타입 추론
fun isEven(n: Int) = n % 2 == 0

fun main() {
    println(add(10, 20))  // 30
    println(isEven(4))    // true
}
```

---

# 매개변수

## 기본값 매개변수

```kotlin
fun createUser(
    name: String,
    age: Int = 20,          // 기본값
    role: String = "일반"   // 기본값
) {
    println("이름: $name, 나이: $age, 역할: $role")
}

fun main() {
    createUser("홍길동")                    // 이름: 홍길동, 나이: 20, 역할: 일반
    createUser("김철수", 30)               // 이름: 김철수, 나이: 30, 역할: 일반
    createUser("이영희", 25, "관리자")      // 이름: 이영희, 나이: 25, 역할: 관리자
}
```

## 이름 있는 인자 (Named Arguments)

```kotlin
fun sendEmail(
    to: String,
    subject: String,
    body: String,
    cc: String = "",
    isHtml: Boolean = false
) {
    println("To: $to, Subject: $subject")
}

fun main() {
    // 이름으로 전달 (순서 무관)
    sendEmail(
        subject = "회의 안내",
        to = "user@test.com",
        body = "내일 10시 회의입니다",
        isHtml = true
    )
}
```

## 가변 인자 (vararg)

```kotlin
fun sum(vararg numbers: Int): Int {
    return numbers.sum()
}

fun printAll(vararg items: String) {
    for (item in items) {
        println(item)
    }
}

fun main() {
    println(sum(1, 2, 3, 4, 5))  // 15
    printAll("A", "B", "C")

    // 배열을 vararg로 전달 (spread 연산자 *)
    val nums = intArrayOf(1, 2, 3)
    println(sum(*nums))  // 6
}
```

---

# 람다 (Lambda)

## 람다 기본

```kotlin
fun main() {
    // 람다 표현식
    val add = { a: Int, b: Int -> a + b }
    println(add(3, 5))  // 8

    // 타입 명시
    val multiply: (Int, Int) -> Int = { a, b -> a * b }
    println(multiply(4, 5))  // 20

    // 매개변수 1개일 때 it 사용
    val double: (Int) -> Int = { it * 2 }
    println(double(7))  // 14
}
```

## 고차 함수 (Higher-Order Function)

함수를 매개변수로 받거나 반환하는 함수:

```kotlin
// 함수를 매개변수로 받기
fun calculate(a: Int, b: Int, operation: (Int, Int) -> Int): Int {
    return operation(a, b)
}

fun main() {
    val sum = calculate(10, 5) { a, b -> a + b }
    val diff = calculate(10, 5) { a, b -> a - b }
    val product = calculate(10, 5) { a, b -> a * b }

    println("합: $sum, 차: $diff, 곱: $product")
    // 합: 15, 차: 5, 곱: 50
}
```

## 후행 람다 (Trailing Lambda)

마지막 매개변수가 람다일 때 괄호 밖으로 뺄 수 있습니다:

```kotlin
fun repeat(times: Int, action: (Int) -> Unit) {
    for (i in 0 until times) {
        action(i)
    }
}

fun main() {
    // 후행 람다
    repeat(3) { index ->
        println("반복 $index")
    }
    // 반복 0
    // 반복 1
    // 반복 2
}
```

---

# 확장 함수 (Extension Function)

기존 클래스에 새 함수를 추가합니다 (클래스 수정 없이):

```kotlin
// String에 함수 추가
fun String.addExclamation(): String {
    return "$this!"
}

// Int에 함수 추가
fun Int.isPositive(): Boolean = this > 0

// List에 함수 추가
fun List<Int>.secondOrNull(): Int? {
    return if (this.size >= 2) this[1] else null
}

fun main() {
    println("Hello".addExclamation())  // Hello!
    println(5.isPositive())            // true
    println((-3).isPositive())         // false

    val list = listOf(10, 20, 30)
    println(list.secondOrNull())  // 20
}
```

---

# 스코프 함수

| 함수 | 객체 참조 | 반환값 | 용도 |
|:---:|:---:|:---:|:---:|
| let | it | 람다 결과 | null 체크, 변환 |
| run | this | 람다 결과 | 객체 설정 + 결과 |
| with | this | 람다 결과 | 객체의 함수 호출 |
| apply | this | 객체 자체 | 객체 초기화 |
| also | it | 객체 자체 | 부가 작업 (로깅 등) |

```kotlin
data class User(var name: String, var age: Int, var email: String = "")

fun main() {
    // apply: 객체 초기화
    val user = User("홍길동", 25).apply {
        email = "hong@test.com"
    }

    // let: null 체크
    val name: String? = "Kotlin"
    name?.let {
        println("길이: ${it.length}")
    }

    // also: 부가 작업
    val numbers = mutableListOf(1, 2, 3).also {
        println("초기 리스트: $it")
    }

    // run: 계산 후 결과 반환
    val result = user.run {
        "$name ($age세) - $email"
    }
    println(result)  // 홍길동 (25세) - hong@test.com
}
```

---

# 실습 예제

## 간단한 계산기

```kotlin
fun calculator(a: Double, b: Double, op: String): Double {
    return when (op) {
        "+" -> a + b
        "-" -> a - b
        "*" -> a * b
        "/" -> if (b != 0.0) a / b else throw ArithmeticException("0으로 나눌 수 없습니다")
        else -> throw IllegalArgumentException("잘못된 연산자: $op")
    }
}

fun main() {
    println(calculator(10.0, 3.0, "+"))  // 13.0
    println(calculator(10.0, 3.0, "/"))  // 3.333...

    try {
        calculator(10.0, 0.0, "/")
    } catch (e: ArithmeticException) {
        println(e.message)
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
