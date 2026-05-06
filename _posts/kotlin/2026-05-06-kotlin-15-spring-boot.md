---
title: "[Kotlin] 15. 서버 개발 - Spring Boot with Kotlin"
categories: 
    - kotlin
tags: 
    [kotlin, spring, 서버, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin으로 Spring Boot 서버를 개발하는 방법을 배웁니다.

# Spring Boot + Kotlin

## 프로젝트 생성

[Spring Initializr](https://start.spring.io){:target="_blank"} 에서 생성:
- Language: **Kotlin**
- Build: Gradle - Kotlin
- Dependencies: Spring Web, Spring Data JPA, H2 Database

## build.gradle.kts

```kotlin
plugins {
    kotlin("jvm") version "1.9.0"
    kotlin("plugin.spring") version "1.9.0"
    kotlin("plugin.jpa") version "1.9.0"
    id("org.springframework.boot") version "3.2.0"
    id("io.spring.dependency-management") version "1.1.0"
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    runtimeOnly("com.h2database:h2")
}
```

---

# REST API 만들기

## 1. Entity

```kotlin
import jakarta.persistence.*

@Entity
@Table(name = "todos")
data class Todo(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false)
    var title: String,

    var description: String? = null,

    var isDone: Boolean = false,

    val createdAt: java.time.LocalDateTime = java.time.LocalDateTime.now()
)
```

## 2. Repository

```kotlin
import org.springframework.data.jpa.repository.JpaRepository

interface TodoRepository : JpaRepository<Todo, Long> {
    fun findByIsDone(isDone: Boolean): List<Todo>
    fun findByTitleContaining(keyword: String): List<Todo>
}
```

## 3. Service

```kotlin
import org.springframework.stereotype.Service

@Service
class TodoService(private val repository: TodoRepository) {

    fun getAll(): List<Todo> = repository.findAll()

    fun getById(id: Long): Todo =
        repository.findById(id).orElseThrow {
            NoSuchElementException("Todo not found: $id")
        }

    fun create(title: String, description: String?): Todo {
        val todo = Todo(title = title, description = description)
        return repository.save(todo)
    }

    fun update(id: Long, title: String?, description: String?, isDone: Boolean?): Todo {
        val todo = getById(id)
        title?.let { todo.title = it }
        description?.let { todo.description = it }
        isDone?.let { todo.isDone = it }
        return repository.save(todo)
    }

    fun delete(id: Long) {
        repository.deleteById(id)
    }

    fun search(keyword: String): List<Todo> =
        repository.findByTitleContaining(keyword)
}
```

## 4. Controller

```kotlin
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/todos")
class TodoController(private val service: TodoService) {

    // GET /api/todos
    @GetMapping
    fun getAll(): List<Todo> = service.getAll()

    // GET /api/todos/1
    @GetMapping("/{id}")
    fun getById(@PathVariable id: Long): Todo = service.getById(id)

    // POST /api/todos
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun create(@RequestBody request: CreateTodoRequest): Todo =
        service.create(request.title, request.description)

    // PUT /api/todos/1
    @PutMapping("/{id}")
    fun update(@PathVariable id: Long, @RequestBody request: UpdateTodoRequest): Todo =
        service.update(id, request.title, request.description, request.isDone)

    // DELETE /api/todos/1
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun delete(@PathVariable id: Long) = service.delete(id)

    // GET /api/todos/search?keyword=공부
    @GetMapping("/search")
    fun search(@RequestParam keyword: String): List<Todo> =
        service.search(keyword)
}

// 요청 DTO
data class CreateTodoRequest(
    val title: String,
    val description: String? = null
)

data class UpdateTodoRequest(
    val title: String? = null,
    val description: String? = null,
    val isDone: Boolean? = null
)
```

---

# 예외 처리

```kotlin
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(NoSuchElementException::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleNotFound(e: NoSuchElementException): ErrorResponse {
        return ErrorResponse(
            status = 404,
            message = e.message ?: "리소스를 찾을 수 없습니다"
        )
    }

    @ExceptionHandler(IllegalArgumentException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleBadRequest(e: IllegalArgumentException): ErrorResponse {
        return ErrorResponse(
            status = 400,
            message = e.message ?: "잘못된 요청입니다"
        )
    }
}

data class ErrorResponse(val status: Int, val message: String)
```

---

# 설정 파일

```yaml
# src/main/resources/application.yml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  h2:
    console:
      enabled: true
      path: /h2-console
```

---

# 실행 및 테스트

```bash
# 실행
./gradlew bootRun
```

```bash
# API 테스트 (curl)
# 생성
curl -X POST http://localhost:8080/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Kotlin 공부","description":"코루틴 학습"}'

# 조회
curl http://localhost:8080/api/todos

# 수정
curl -X PUT http://localhost:8080/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"isDone":true}'

# 삭제
curl -X DELETE http://localhost:8080/api/todos/1
```

---

# Kotlin + Spring 장점

| 기능 | 설명 |
|------|------|
| data class | DTO/Entity 간결하게 정의 |
| null safety | NPE 방지 |
| 확장 함수 | 유틸리티 깔끔하게 추가 |
| 코루틴 | WebFlux와 자연스러운 통합 |
| 기본값 매개변수 | 빌더 패턴 불필요 |

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
