---
title: "[Kotlin] 05. 클래스와 객체지향 프로그래밍"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 클래스, 상속, 인터페이스 등 OOP 핵심 개념을 배웁니다.

# 클래스 기본

## 클래스 선언

```kotlin
// 기본 클래스
class Person(val name: String, var age: Int) {
    fun introduce() {
        println("안녕하세요, ${name}입니다. ${age}세입니다.")
    }
}

fun main() {
    val person = Person("홍길동", 25)  // new 키워드 불필요
    person.introduce()
    person.age = 26  // var이므로 변경 가능
    // person.name = "김철수"  // val이므로 변경 불가
}
```

## 생성자

### 주 생성자 (Primary Constructor)

```kotlin
class User(
    val name: String,
    val email: String,
    var age: Int = 20  // 기본값
) {
    // init 블록: 초기화 로직
    init {
        require(age > 0) { "나이는 양수여야 합니다" }
        println("$name 생성됨")
    }
}
```

### 보조 생성자 (Secondary Constructor)

```kotlin
class Product {
    val name: String
    val price: Int
    val category: String

    constructor(name: String, price: Int) {
        this.name = name
        this.price = price
        this.category = "기타"
    }

    constructor(name: String, price: Int, category: String) {
        this.name = name
        this.price = price
        this.category = category
    }
}

fun main() {
    val p1 = Product("노트북", 1500000)
    val p2 = Product("키보드", 80000, "주변기기")
}
```

---

## data class

equals, hashCode, toString, copy를 자동 생성합니다.

```kotlin
data class User(
    val id: Int,
    val name: String,
    val email: String
)

fun main() {
    val user1 = User(1, "홍길동", "hong@test.com")
    val user2 = User(1, "홍길동", "hong@test.com")

    // toString 자동 생성
    println(user1)  // User(id=1, name=홍길동, email=hong@test.com)

    // equals 자동 생성 (내용 비교)
    println(user1 == user2)  // true

    // copy (일부 값만 변경)
    val user3 = user1.copy(name = "김철수")
    println(user3)  // User(id=1, name=김철수, email=hong@test.com)

    // 구조 분해
    val (id, name, email) = user1
    println("$id, $name, $email")
}
```

---

## 접근 제어자

| 제어자 | 범위 |
|:---:|:---:|
| public | 어디서나 (기본값) |
| private | 같은 파일/클래스 내 |
| protected | 같은 클래스 + 하위 클래스 |
| internal | 같은 모듈 내 |

```kotlin
class BankAccount(private var balance: Double) {
    // private: 외부 접근 불가
    fun deposit(amount: Double) {
        if (amount > 0) balance += amount
    }

    fun withdraw(amount: Double): Boolean {
        return if (amount in 0.0..balance) {
            balance -= amount
            true
        } else false
    }

    fun getBalance() = balance
}
```

---

# 상속

Kotlin 클래스는 기본적으로 `final`입니다. 상속하려면 `open` 키워드가 필요합니다.

```kotlin
// open: 상속 허용
open class Animal(val name: String) {
    open fun speak() {  // open: 오버라이드 허용
        println("$name 이(가) 소리를 냅니다")
    }
}

class Dog(name: String) : Animal(name) {
    override fun speak() {
        println("$name: 멍멍!")
    }

    fun fetch() {
        println("$name 이(가) 공을 가져옵니다")
    }
}

class Cat(name: String) : Animal(name) {
    override fun speak() {
        println("$name: 야옹~")
    }
}

fun main() {
    val animals: List<Animal> = listOf(Dog("바둑이"), Cat("나비"))
    for (animal in animals) {
        animal.speak()
    }
    // 바둑이: 멍멍!
    // 나비: 야옹~
}
```

---

# 추상 클래스와 인터페이스

## abstract class

```kotlin
abstract class Shape {
    abstract fun area(): Double
    abstract fun perimeter(): Double

    // 일반 메서드도 가능
    fun printInfo() {
        println("넓이: ${area()}, 둘레: ${perimeter()}")
    }
}

class Circle(val radius: Double) : Shape() {
    override fun area() = Math.PI * radius * radius
    override fun perimeter() = 2 * Math.PI * radius
}

class Rectangle(val width: Double, val height: Double) : Shape() {
    override fun area() = width * height
    override fun perimeter() = 2 * (width + height)
}
```

## interface

```kotlin
interface Clickable {
    fun click()
    fun showOff() = println("Clickable!")  // 기본 구현 가능
}

interface Focusable {
    fun focus()
    fun showOff() = println("Focusable!")
}

// 다중 인터페이스 구현
class Button : Clickable, Focusable {
    override fun click() = println("버튼 클릭됨")
    override fun focus() = println("포커스 됨")

    // 충돌 시 명시적 선택
    override fun showOff() {
        super<Clickable>.showOff()
        super<Focusable>.showOff()
    }
}
```

---

# object / companion object

## object (싱글톤)

```kotlin
object DatabaseConfig {
    val host = "localhost"
    val port = 3306

    fun getConnectionString(): String {
        return "jdbc:mysql://$host:$port/mydb"
    }
}

fun main() {
    println(DatabaseConfig.getConnectionString())
}
```

## companion object (정적 멤버)

```kotlin
class User private constructor(val name: String, val age: Int) {
    companion object {
        // Java의 static과 유사
        fun create(name: String, age: Int): User {
            require(age > 0)
            return User(name, age)
        }

        fun fromJson(json: Map<String, Any>): User {
            return User(
                json["name"] as String,
                json["age"] as Int
            )
        }
    }
}

fun main() {
    val user = User.create("홍길동", 25)
    println(user.name)
}
```

---

# enum class

```kotlin
enum class Direction {
    NORTH, SOUTH, EAST, WEST
}

enum class Color(val hex: String) {
    RED("#FF0000"),
    GREEN("#00FF00"),
    BLUE("#0000FF");

    fun printInfo() = println("$name: $hex")
}

fun main() {
    val dir = Direction.NORTH
    println(dir)  // NORTH

    Color.RED.printInfo()  // RED: #FF0000

    // when과 함께
    val message = when (dir) {
        Direction.NORTH -> "북쪽"
        Direction.SOUTH -> "남쪽"
        Direction.EAST -> "동쪽"
        Direction.WEST -> "서쪽"
    }
}
```

---

# sealed class

제한된 상속 계층을 정의합니다. when에서 else 불필요:

```kotlin
sealed class Result {
    data class Success(val data: String) : Result()
    data class Error(val message: String) : Result()
    object Loading : Result()
}

fun handleResult(result: Result) {
    when (result) {
        is Result.Success -> println("성공: ${result.data}")
        is Result.Error -> println("에러: ${result.message}")
        is Result.Loading -> println("로딩 중...")
        // else 불필요 (모든 경우 처리됨)
    }
}

fun main() {
    handleResult(Result.Success("데이터 로드 완료"))
    handleResult(Result.Error("네트워크 오류"))
    handleResult(Result.Loading)
}
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
