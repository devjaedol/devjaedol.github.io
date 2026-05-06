---
title: "[Kotlin] 03. 제어문 - 조건문, 반복문"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 조건문과 반복문으로 프로그램 흐름을 제어합니다.

# 조건문

## if / else

Kotlin에서 `if`는 표현식(expression)입니다. 값을 반환할 수 있습니다.

```kotlin
fun main() {
    val score = 85

    // 기본 if-else
    if (score >= 90) {
        println("A등급")
    } else if (score >= 80) {
        println("B등급")
    } else if (score >= 70) {
        println("C등급")
    } else {
        println("F등급")
    }

    // if를 표현식으로 사용 (삼항 연산자 대체)
    val grade = if (score >= 90) "A" else if (score >= 80) "B" else "C"
    println(grade)  // B

    // 블록에서 마지막 값이 반환됨
    val result = if (score >= 80) {
        println("합격!")
        "PASS"  // 반환값
    } else {
        println("불합격")
        "FAIL"  // 반환값
    }
}
```

---

## when (switch 대체)

Java의 switch보다 훨씬 강력합니다.

```kotlin
fun main() {
    val day = 3

    // 기본 when
    when (day) {
        1 -> println("월요일")
        2 -> println("화요일")
        3 -> println("수요일")
        4 -> println("목요일")
        5 -> println("금요일")
        6, 7 -> println("주말")  // 여러 값 매칭
        else -> println("잘못된 값")
    }

    // when을 표현식으로
    val dayName = when (day) {
        1 -> "월요일"
        2 -> "화요일"
        3 -> "수요일"
        else -> "기타"
    }
    println(dayName)  // 수요일
}
```

### when 다양한 활용

```kotlin
fun main() {
    val x = 15

    // 범위 매칭
    val category = when (x) {
        in 1..10 -> "한 자리"
        in 11..99 -> "두 자리"
        in 100..999 -> "세 자리"
        else -> "기타"
    }
    println(category)  // 두 자리

    // 타입 매칭
    val value: Any = "Hello"
    when (value) {
        is String -> println("문자열: ${value.length}자")
        is Int -> println("정수: $value")
        is Boolean -> println("불리언: $value")
        else -> println("기타 타입")
    }

    // 조건 없는 when (if-else 대체)
    val score = 85
    val grade = when {
        score >= 90 -> "A"
        score >= 80 -> "B"
        score >= 70 -> "C"
        else -> "F"
    }
    println(grade)  // B
}
```

---

# 반복문

## for 문

```kotlin
fun main() {
    // 범위 (Range)
    for (i in 1..5) {
        print("$i ")  // 1 2 3 4 5
    }
    println()

    // until (마지막 제외)
    for (i in 0 until 5) {
        print("$i ")  // 0 1 2 3 4
    }
    println()

    // 역순
    for (i in 5 downTo 1) {
        print("$i ")  // 5 4 3 2 1
    }
    println()

    // step (간격)
    for (i in 0..10 step 2) {
        print("$i ")  // 0 2 4 6 8 10
    }
    println()

    // 컬렉션 순회
    val fruits = listOf("사과", "바나나", "포도")
    for (fruit in fruits) {
        println(fruit)
    }

    // 인덱스와 함께
    for ((index, fruit) in fruits.withIndex()) {
        println("$index: $fruit")
    }
}
```

## while / do-while

```kotlin
fun main() {
    // while
    var count = 0
    while (count < 3) {
        println("while: $count")
        count++
    }

    // do-while (최소 1번 실행)
    var num = 5
    do {
        println("do-while: $num")
        num++
    } while (num < 3)  // 조건 false지만 1번 실행됨
}
```

## break / continue / 라벨

```kotlin
fun main() {
    // break
    for (i in 1..10) {
        if (i == 5) break
        print("$i ")  // 1 2 3 4
    }
    println()

    // continue
    for (i in 1..5) {
        if (i == 3) continue
        print("$i ")  // 1 2 4 5
    }
    println()

    // 라벨 (중첩 반복문 탈출)
    outer@ for (i in 1..3) {
        for (j in 1..3) {
            if (i == 2 && j == 2) break@outer
            println("$i, $j")
        }
    }
}
```

---

# 범위 (Range)

```kotlin
fun main() {
    // 정수 범위
    val range1 = 1..10       // 1부터 10까지 (포함)
    val range2 = 1 until 10  // 1부터 9까지 (10 제외)

    // 포함 여부 확인
    println(5 in range1)   // true
    println(10 in range2)  // false

    // 문자 범위
    val charRange = 'a'..'z'
    println('k' in charRange)  // true

    // 조건문에서 활용
    val age = 25
    val category = when (age) {
        in 0..12 -> "어린이"
        in 13..18 -> "청소년"
        in 19..64 -> "성인"
        else -> "노인"
    }
    println(category)  // 성인
}
```

---

# 실습 예제

## 구구단

```kotlin
fun main() {
    for (i in 2..9) {
        println("--- ${i}단 ---")
        for (j in 1..9) {
            println("$i x $j = ${i * j}")
        }
    }
}
```

## FizzBuzz

```kotlin
fun main() {
    for (i in 1..30) {
        val result = when {
            i % 15 == 0 -> "FizzBuzz"
            i % 3 == 0 -> "Fizz"
            i % 5 == 0 -> "Buzz"
            else -> "$i"
        }
        println(result)
    }
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
