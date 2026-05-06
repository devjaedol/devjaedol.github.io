---
title: "[Kotlin] 02. 변수와 데이터 타입"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 변수 선언 방법과 기본 데이터 타입을 배웁니다.

# 변수 선언

## val vs var

```kotlin
fun main() {
    // val: 읽기 전용 (재할당 불가, Java의 final)
    val name = "홍길동"
    // name = "김철수"  // 에러! 재할당 불가

    // var: 변경 가능
    var age = 25
    age = 26  // OK

    println("$name, $age세")
}
```

> 가능하면 `val`을 사용하고, 변경이 필요할 때만 `var`을 사용합니다.

## 타입 추론 vs 명시적 선언

```kotlin
fun main() {
    // 타입 추론 (컴파일러가 자동 판단)
    val city = "서울"          // String
    val count = 10             // Int
    val price = 99.9           // Double
    val isActive = true        // Boolean

    // 명시적 타입 선언
    val name: String = "Kotlin"
    val number: Int = 42
    val rate: Double = 3.14

    // 선언과 초기화 분리 (타입 필수)
    val result: String
    result = "나중에 할당"
}
```

---

# 기본 데이터 타입

Kotlin에서는 모든 것이 객체입니다 (원시 타입 없음).

| 타입 | 크기 | 범위 | 예시 |
|:---:|:---:|:---:|:---:|
| Byte | 8bit | -128 ~ 127 | `val b: Byte = 1` |
| Short | 16bit | -32768 ~ 32767 | `val s: Short = 100` |
| Int | 32bit | -2^31 ~ 2^31-1 | `val i = 42` |
| Long | 64bit | -2^63 ~ 2^63-1 | `val l = 100L` |
| Float | 32bit | 소수점 6~7자리 | `val f = 3.14f` |
| Double | 64bit | 소수점 15~16자리 | `val d = 3.14` |
| Boolean | - | true / false | `val b = true` |
| Char | 16bit | 단일 문자 | `val c = 'A'` |
| String | - | 문자열 | `val s = "Hello"` |

```kotlin
fun main() {
    val intNum = 100          // Int
    val longNum = 100L        // Long (L 접미사)
    val floatNum = 3.14f      // Float (f 접미사)
    val doubleNum = 3.14      // Double

    // 큰 숫자 가독성 (언더스코어)
    val million = 1_000_000
    val hexColor = 0xFF0000
    val binary = 0b1010

    println(million)  // 1000000
}
```

---

# 문자열

## 문자열 템플릿

```kotlin
fun main() {
    val name = "Kotlin"
    val version = 1.9

    // $ 변수명
    println("언어: $name")

    // ${표현식}
    println("버전: ${version + 0.1}")
    println("길이: ${name.length}자")
}
```

## 여러 줄 문자열

```kotlin
fun main() {
    val text = """
        |첫 번째 줄
        |두 번째 줄
        |세 번째 줄
    """.trimMargin()

    println(text)
}
```

## 문자열 주요 메서드

```kotlin
fun main() {
    val str = "Hello, Kotlin!"

    println(str.length)           // 14
    println(str.uppercase())      // HELLO, KOTLIN!
    println(str.lowercase())      // hello, kotlin!
    println(str.contains("Kotlin")) // true
    println(str.replace("Kotlin", "World")) // Hello, World!
    println(str.substring(0, 5))  // Hello
    println(str.split(", "))      // [Hello, Kotlin!]
    println(str.trim())           // 앞뒤 공백 제거
    println(str.startsWith("Hello")) // true
    println(str.isEmpty())        // false
}
```

---

# Null Safety

Kotlin의 가장 큰 장점 중 하나입니다.

## 기본: null 불가

```kotlin
fun main() {
    var name: String = "홍길동"
    // name = null  // 컴파일 에러!
}
```

## nullable 타입 (?)

```kotlin
fun main() {
    var nickname: String? = "길동이"
    nickname = null  // OK

    // 안전 호출 연산자 (?.)
    println(nickname?.length)  // null (에러 없음)

    // 엘비스 연산자 (?:) - null이면 기본값
    val displayName = nickname ?: "이름없음"
    println(displayName)  // 이름없음

    // non-null 단언 (!!) - null이면 예외 발생 (주의!)
    // println(nickname!!.length)  // NullPointerException!
}
```

## 안전한 null 처리 패턴

```kotlin
fun main() {
    val text: String? = "Hello"

    // 방법 1: if 체크
    if (text != null) {
        println(text.length)  // 스마트 캐스트: String으로 자동 변환
    }

    // 방법 2: let (null이 아닐 때만 실행)
    text?.let {
        println(it.length)
        println(it.uppercase())
    }

    // 방법 3: 엘비스 연산자로 기본값
    val length = text?.length ?: 0
}
```

---

# 타입 변환

```kotlin
fun main() {
    // 숫자 변환
    val intNum = 42
    val longNum = intNum.toLong()
    val doubleNum = intNum.toDouble()
    val floatNum = intNum.toFloat()

    // 문자열 → 숫자
    val str = "123"
    val num = str.toInt()
    val numOrNull = "abc".toIntOrNull()  // null (안전한 변환)

    // 숫자 → 문자열
    val numStr = 42.toString()

    // 타입 체크
    val value: Any = "Hello"
    if (value is String) {
        println(value.length)  // 스마트 캐스트
    }

    // 안전한 캐스팅
    val result = value as? Int  // null (실패 시 null)
    println(numOrNull)  // null
}
```

---

# 배열과 컬렉션 미리보기

```kotlin
fun main() {
    // 배열
    val numbers = arrayOf(1, 2, 3, 4, 5)
    println(numbers[0])  // 1

    // 리스트 (읽기 전용)
    val fruits = listOf("사과", "바나나", "포도")

    // 리스트 (변경 가능)
    val mutableList = mutableListOf("A", "B", "C")
    mutableList.add("D")

    // 맵
    val scores = mapOf("국어" to 90, "영어" to 85)
    println(scores["국어"])  // 90
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
