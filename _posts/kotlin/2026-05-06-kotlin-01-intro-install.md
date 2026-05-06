---
title: "[Kotlin] 01. Kotlin 소개 및 개발환경 설치"
categories: 
    - kotlin
tags: 
    [kotlin, 초급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin의 개념을 이해하고 개발환경을 설치합니다.

# Kotlin이란?

JetBrains가 개발한 현대적인 프로그래밍 언어로, 2017년 Google이 Android 공식 언어로 채택했습니다.  
Java와 100% 호환되면서 더 간결하고 안전한 코드를 작성할 수 있습니다.

## Kotlin 특징

| 특징 | 설명 |
|:---:|:---:|
| Java 호환 | JVM 위에서 실행, Java 라이브러리 사용 가능 |
| Null Safety | 컴파일 타임에 NullPointerException 방지 |
| 간결한 문법 | Java 대비 코드량 40% 감소 |
| 코루틴 | 비동기 프로그래밍 내장 지원 |
| 멀티플랫폼 | Android, Server, Web, iOS 지원 |
| 함수형 프로그래밍 | 람다, 고차함수 지원 |

## Kotlin vs Java 비교

| 항목 | Kotlin | Java |
|:---:|:---:|:---:|
| Null 안전성 | 기본 지원 | Optional 사용 |
| 데이터 클래스 | `data class` 한 줄 | getter/setter/equals 직접 작성 |
| 세미콜론 | 불필요 | 필수 |
| 타입 추론 | 강력 | 제한적 (var, Java 10+) |
| 확장 함수 | 지원 | 미지원 |
| 코루틴 | 내장 | 외부 라이브러리 필요 |
| 스마트 캐스트 | 자동 | instanceof + 캐스팅 |
| 문자열 템플릿 | `"$name"` | `String.format()` |

---

## Kotlin 활용 분야

| 분야 | 설명 |
|------|------|
| Android 앱 | Google 공식 권장 언어 |
| 서버 (Spring Boot) | Java 대체로 사용 증가 |
| Kotlin Multiplatform | iOS/Android 공유 로직 |
| Kotlin/JS | JavaScript 타겟 컴파일 |
| Gradle 스크립트 | build.gradle.kts |

---

# 개발환경 설치

## 1. IntelliJ IDEA (권장)

1. [IntelliJ IDEA 다운로드](https://www.jetbrains.com/idea/download/){:target="_blank"} (Community 무료)
2. 설치 후 New Project → Kotlin 선택
3. JDK 설정 (17 이상 권장)

## 2. Android Studio

Android 개발 시 사용:
1. [Android Studio 다운로드](https://developer.android.com/studio){:target="_blank"}
2. Kotlin 플러그인 기본 포함

## 3. VS Code

```bash
# Kotlin 확장 설치
# Extensions에서 "Kotlin" 검색 후 설치
```

## 4. 온라인 실행

설치 없이 바로 실행: [https://play.kotlinlang.org](https://play.kotlinlang.org){:target="_blank"}

---

# 첫 번째 프로그램

## Hello World

```kotlin
fun main() {
    println("Hello, Kotlin!")
}
```

## 실행 방법

### IntelliJ IDEA
- `main` 함수 옆 ▶ 버튼 클릭

### 커맨드라인
```bash
# 컴파일
kotlinc hello.kt -include-runtime -d hello.jar

# 실행
java -jar hello.jar
```

### Kotlin Script (.kts)
```bash
# 스크립트 실행 (컴파일 없이)
kotlinc-jvm -script hello.kts
```

---

# 프로젝트 구조 (Gradle)

```bash
# Gradle 프로젝트 생성
gradle init --type kotlin-application
```

```
my-kotlin-app/
├── build.gradle.kts    # 빌드 설정
├── settings.gradle.kts
├── gradle/
└── src/
    ├── main/
    │   └── kotlin/
    │       └── Main.kt  # 소스 코드
    └── test/
        └── kotlin/
            └── MainTest.kt
```

## build.gradle.kts 기본

```kotlin
plugins {
    kotlin("jvm") version "1.9.0"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

application {
    mainClass.set("MainKt")
}
```

---

# 유용한 명령어

| 명령어 | 설명 |
|--------|------|
| `kotlinc` | Kotlin 컴파일러 |
| `kotlin` | Kotlin 프로그램 실행 |
| `gradle build` | 프로젝트 빌드 |
| `gradle run` | 프로젝트 실행 |
| `gradle test` | 테스트 실행 |

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
