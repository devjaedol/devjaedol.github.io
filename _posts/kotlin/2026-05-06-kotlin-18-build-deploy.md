---
title: "[Kotlin] 18. 빌드와 배포 - Gradle, APK, JAR"
categories: 
    - kotlin
tags: 
    [kotlin, android, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin 프로젝트를 빌드하고 배포하는 방법을 배웁니다.

# Gradle 기본

## build.gradle.kts 구조

```kotlin
plugins {
    kotlin("jvm") version "1.9.0"
    application
}

group = "com.example"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    testImplementation(kotlin("test"))
}

application {
    mainClass.set("com.example.MainKt")
}

tasks.test {
    useJUnitPlatform()
}

// Fat JAR (의존성 포함)
tasks.jar {
    manifest {
        attributes["Main-Class"] = "com.example.MainKt"
    }
    from(configurations.runtimeClasspath.get().map { if (it.isDirectory) it else zipTree(it) })
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
}
```

## 주요 Gradle 명령어

| 명령어 | 설명 |
|--------|------|
| `./gradlew build` | 빌드 (컴파일 + 테스트) |
| `./gradlew run` | 실행 |
| `./gradlew test` | 테스트만 실행 |
| `./gradlew jar` | JAR 파일 생성 |
| `./gradlew clean` | 빌드 캐시 삭제 |
| `./gradlew dependencies` | 의존성 트리 확인 |

---

# JVM 애플리케이션 배포

## JAR 파일 생성

```bash
# 빌드
./gradlew build

# JAR 생성
./gradlew jar

# 실행
java -jar build/libs/my-app-1.0.0.jar
```

## Shadow JAR (Fat JAR)

모든 의존성을 하나의 JAR에 포함:

```kotlin
// build.gradle.kts
plugins {
    id("com.github.johnrengelman.shadow") version "8.1.1"
}

tasks.shadowJar {
    archiveBaseName.set("my-app")
    archiveVersion.set("1.0.0")
    archiveClassifier.set("")
    manifest {
        attributes["Main-Class"] = "com.example.MainKt"
    }
}
```

```bash
./gradlew shadowJar
java -jar build/libs/my-app-1.0.0.jar
```

---

# Spring Boot 배포

```bash
# 실행 가능한 JAR 생성
./gradlew bootJar

# 실행
java -jar build/libs/my-app-0.0.1-SNAPSHOT.jar

# 프로파일 지정
java -jar my-app.jar --spring.profiles.active=prod
```

## Docker 배포

```dockerfile
# Dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY build/libs/my-app-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
# 빌드 & 실행
docker build -t my-kotlin-app .
docker run -p 8080:8080 my-kotlin-app
```

---

# Android 빌드

## 서명 키 생성

```bash
keytool -genkey -v -keystore my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

## 서명 설정

```kotlin
// app/build.gradle.kts
android {
    signingConfigs {
        create("release") {
            storeFile = file("my-release-key.jks")
            storePassword = "비밀번호"
            keyAlias = "my-key-alias"
            keyPassword = "비밀번호"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // 코드 축소
            isShrinkResources = true  // 리소스 축소
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## APK / AAB 빌드

```bash
# Debug APK
./gradlew assembleDebug

# Release APK
./gradlew assembleRelease

# AAB (Google Play 업로드용)
./gradlew bundleRelease
```

빌드 결과:
```
app/build/outputs/apk/release/app-release.apk
app/build/outputs/bundle/release/app-release.aab
```

## Google Play 배포 절차

1. [Google Play Console](https://play.google.com/console){:target="_blank"} 접속
2. 앱 만들기
3. 스토어 등록 정보 작성 (스크린샷, 설명)
4. AAB 파일 업로드
5. 심사 제출

---

# CI/CD (GitHub Actions)

## Kotlin JVM 프로젝트

```yaml
# .github/workflows/build.yml
name: Build

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Build
        run: ./gradlew build
      - name: Test
        run: ./gradlew test
```

## Android 프로젝트

```yaml
# .github/workflows/android.yml
name: Android Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Build Debug APK
        run: ./gradlew assembleDebug
      - name: Run Tests
        run: ./gradlew test
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
```

---

# 버전 관리

```kotlin
// build.gradle.kts
android {
    defaultConfig {
        versionCode = 4        // 매 업로드마다 증가 (정수)
        versionName = "1.2.3"  // 사용자에게 보이는 버전
    }
}
```

| 버전 | 의미 |
|------|------|
| 1.0.0 | 최초 릴리즈 |
| 1.0.1 | 버그 수정 |
| 1.1.0 | 기능 추가 |
| 2.0.0 | 대규모 변경 |

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
