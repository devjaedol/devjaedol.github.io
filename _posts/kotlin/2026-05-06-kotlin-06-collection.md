---
title: "[Kotlin] 06. 컬렉션 - List, Map, Set"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 컬렉션 타입과 다양한 함수형 연산을 배웁니다.

# 컬렉션 종류

| 타입 | 읽기 전용 | 변경 가능 |
|:---:|:---:|:---:|
| List | `listOf()` | `mutableListOf()` |
| Set | `setOf()` | `mutableSetOf()` |
| Map | `mapOf()` | `mutableMapOf()` |

---

# List

## 읽기 전용 List

```kotlin
fun main() {
    val fruits = listOf("사과", "바나나", "포도", "딸기")

    println(fruits[0])          // 사과
    println(fruits.size)        // 4
    println(fruits.first())     // 사과
    println(fruits.last())      // 딸기
    println(fruits.contains("포도"))  // true
    println("바나나" in fruits)       // true
    println(fruits.indexOf("포도"))   // 2
}
```

## 변경 가능 MutableList

```kotlin
fun main() {
    val numbers = mutableListOf(1, 2, 3)

    numbers.add(4)           // 끝에 추가
    numbers.add(0, 0)        // 인덱스 0에 추가
    numbers.addAll(listOf(5, 6))  // 여러 개 추가
    numbers.remove(3)        // 값으로 삭제
    numbers.removeAt(0)      // 인덱스로 삭제

    println(numbers)  // [1, 2, 4, 5, 6]

    numbers.sort()           // 정렬
    numbers.reverse()        // 역순
    numbers.shuffle()        // 섞기
    numbers.clear()          // 전체 삭제
}
```

---

# Map

## 읽기 전용 Map

```kotlin
fun main() {
    val scores = mapOf(
        "국어" to 90,
        "영어" to 85,
        "수학" to 95
    )

    println(scores["국어"])       // 90
    println(scores.getOrDefault("과학", 0))  // 0
    println(scores.keys)         // [국어, 영어, 수학]
    println(scores.values)       // [90, 85, 95]
    println(scores.size)         // 3
    println("영어" in scores)    // true

    // 순회
    for ((subject, score) in scores) {
        println("$subject: ${score}점")
    }
}
```

## 변경 가능 MutableMap

```kotlin
fun main() {
    val userMap = mutableMapOf<String, Int>()

    userMap["홍길동"] = 25       // 추가
    userMap["김철수"] = 30
    userMap["이영희"] = 28

    userMap["홍길동"] = 26       // 수정
    userMap.remove("김철수")     // 삭제

    println(userMap)  // {홍길동=26, 이영희=28}

    // putIfAbsent: 없을 때만 추가
    userMap.putIfAbsent("홍길동", 99)  // 이미 있으므로 무시
    userMap.putIfAbsent("박민수", 22)  // 추가됨
}
```

---

# Set

중복을 허용하지 않는 컬렉션:

```kotlin
fun main() {
    val colors = setOf("빨강", "파랑", "초록", "빨강")
    println(colors)       // [빨강, 파랑, 초록] (중복 제거)
    println(colors.size)  // 3

    val mutableSet = mutableSetOf(1, 2, 3)
    mutableSet.add(4)     // 추가
    mutableSet.add(2)     // 이미 있으므로 무시
    mutableSet.remove(1)  // 삭제

    // 집합 연산
    val setA = setOf(1, 2, 3, 4)
    val setB = setOf(3, 4, 5, 6)

    println(setA union setB)     // [1, 2, 3, 4, 5, 6] (합집합)
    println(setA intersect setB) // [3, 4] (교집합)
    println(setA subtract setB)  // [1, 2] (차집합)
}
```

---

# 컬렉션 함수형 연산

## filter / map

```kotlin
fun main() {
    val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // filter: 조건에 맞는 요소만
    val evens = numbers.filter { it % 2 == 0 }
    println(evens)  // [2, 4, 6, 8, 10]

    // map: 변환
    val doubled = numbers.map { it * 2 }
    println(doubled)  // [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

    // 체이닝
    val result = numbers
        .filter { it % 2 == 0 }
        .map { it * it }
    println(result)  // [4, 16, 36, 64, 100]
}
```

## 기타 유용한 함수

```kotlin
fun main() {
    val numbers = listOf(5, 2, 8, 1, 9, 3, 7)

    // 정렬
    println(numbers.sorted())          // [1, 2, 3, 5, 7, 8, 9]
    println(numbers.sortedDescending()) // [9, 8, 7, 5, 3, 2, 1]

    // 집계
    println(numbers.sum())     // 35
    println(numbers.average()) // 5.0
    println(numbers.max())     // 9
    println(numbers.min())     // 1
    println(numbers.count())   // 7

    // 조건 확인
    println(numbers.any { it > 5 })    // true (하나라도)
    println(numbers.all { it > 0 })    // true (모두)
    println(numbers.none { it > 10 })  // true (하나도 없음)

    // 찾기
    println(numbers.first { it > 5 })       // 8
    println(numbers.firstOrNull { it > 10 }) // null
    println(numbers.find { it > 5 })        // 8

    // 그룹핑
    val words = listOf("apple", "banana", "avocado", "blueberry", "cherry")
    val grouped = words.groupBy { it.first() }
    println(grouped)
    // {a=[apple, avocado], b=[banana, blueberry], c=[cherry]}
}
```

## reduce / fold

```kotlin
fun main() {
    val numbers = listOf(1, 2, 3, 4, 5)

    // reduce: 누적 계산 (초기값 = 첫 번째 요소)
    val sum = numbers.reduce { acc, n -> acc + n }
    println(sum)  // 15

    // fold: 누적 계산 (초기값 지정)
    val sumFrom100 = numbers.fold(100) { acc, n -> acc + n }
    println(sumFrom100)  // 115

    // 문자열 결합
    val joined = numbers.fold("") { acc, n -> "$acc[$n]" }
    println(joined)  // [1][2][3][4][5]
}
```

## flatMap / flatten

```kotlin
fun main() {
    val nested = listOf(
        listOf(1, 2, 3),
        listOf(4, 5, 6),
        listOf(7, 8, 9)
    )

    // flatten: 중첩 리스트 펼치기
    println(nested.flatten())  // [1, 2, 3, 4, 5, 6, 7, 8, 9]

    // flatMap: 변환 + 펼치기
    val words = listOf("Hello", "World")
    val chars = words.flatMap { it.toList() }
    println(chars)  // [H, e, l, l, o, W, o, r, l, d]
}
```

---

# 실습 예제

## 학생 성적 처리

```kotlin
data class Student(val name: String, val score: Int)

fun main() {
    val students = listOf(
        Student("홍길동", 85),
        Student("김철수", 92),
        Student("이영희", 78),
        Student("박민수", 96),
        Student("정수진", 88)
    )

    // 평균
    val avg = students.map { it.score }.average()
    println("평균: ${"%.1f".format(avg)}")

    // 90점 이상
    val topStudents = students.filter { it.score >= 90 }
    println("우수: ${topStudents.map { it.name }}")

    // 점수순 정렬
    val sorted = students.sortedByDescending { it.score }
    sorted.forEachIndexed { index, student ->
        println("${index + 1}등: ${student.name} (${student.score}점)")
    }

    // 합격/불합격 분류
    val (passed, failed) = students.partition { it.score >= 80 }
    println("합격: ${passed.size}명, 불합격: ${failed.size}명")
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
