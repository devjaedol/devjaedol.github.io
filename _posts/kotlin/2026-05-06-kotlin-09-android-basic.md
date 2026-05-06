---
title: "[Kotlin] 09. Android 개발 기초 - 프로젝트 생성"
categories: 
    - kotlin
tags: 
    [kotlin, android, 중급, 'lecture-kotlin']
toc : true
toc_sticky  : true    
---

Kotlin으로 Android 앱 개발을 시작합니다. 프로젝트 생성과 기본 구조를 배웁니다.

# Android 개발환경

## 필요 도구

| 도구 | 용도 |
|------|------|
| Android Studio | 공식 IDE |
| JDK 17+ | Java 런타임 |
| Android SDK | Android API |
| Emulator / 실기기 | 테스트 |

## Android Studio 설치

1. [Android Studio 다운로드](https://developer.android.com/studio){:target="_blank"}
2. 설치 후 SDK Manager에서 최신 SDK 설치
3. AVD Manager에서 에뮬레이터 생성

---

# 프로젝트 생성

## New Project

1. Android Studio → New Project
2. **Empty Activity** 선택 (Compose 기반)
3. 설정:
   - Name: `MyFirstApp`
   - Package name: `com.example.myfirstapp`
   - Language: **Kotlin**
   - Minimum SDK: API 24 (Android 7.0)

---

# 프로젝트 구조

```
app/
├── src/main/
│   ├── java/com/example/myfirstapp/
│   │   └── MainActivity.kt        # 메인 액티비티
│   ├── res/
│   │   ├── layout/                 # XML 레이아웃 (View 방식)
│   │   ├── values/
│   │   │   ├── strings.xml         # 문자열 리소스
│   │   │   ├── colors.xml          # 색상
│   │   │   └── themes.xml          # 테마
│   │   ├── drawable/               # 이미지, 아이콘
│   │   └── mipmap/                 # 앱 아이콘
│   └── AndroidManifest.xml         # 앱 설정 (권한, 액티비티 등)
├── build.gradle.kts                # 앱 빌드 설정
└── gradle/
```

---

# Jetpack Compose 기본

현재 Android 공식 UI 프레임워크는 Jetpack Compose입니다.

## MainActivity.kt

```kotlin
package com.example.myfirstapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    Greeting("Android")
                }
            }
        }
    }
}

@Composable
fun Greeting(name: String) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Hello, $name!",
            fontSize = 24.sp
        )
    }
}
```

---

# Compose UI 기본 요소

## Text

```kotlin
@Composable
fun TextExample() {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("기본 텍스트")
        Text(
            text = "스타일 적용",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Blue
        )
    }
}
```

## Button

```kotlin
@Composable
fun ButtonExample() {
    var count by remember { mutableStateOf(0) }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("클릭 횟수: $count", fontSize = 20.sp)
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { count++ }) {
            Text("클릭!")
        }
    }
}
```

## TextField

```kotlin
@Composable
fun InputExample() {
    var text by remember { mutableStateOf("") }

    Column(modifier = Modifier.padding(16.dp)) {
        OutlinedTextField(
            value = text,
            onValueChange = { text = it },
            label = { Text("이름 입력") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text("입력값: $text")
    }
}
```

---

# 레이아웃

## Column / Row / Box

```kotlin
@Composable
fun LayoutExample() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // 가로 배치
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("왼쪽")
            Text("오른쪽")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // 겹쳐서 배치
        Box(
            modifier = Modifier
                .size(100.dp)
                .background(Color.LightGray),
            contentAlignment = Alignment.Center
        ) {
            Text("중앙")
        }
    }
}
```

## Modifier (수정자)

```kotlin
@Composable
fun ModifierExample() {
    Text(
        text = "Modifier 예제",
        modifier = Modifier
            .fillMaxWidth()           // 가로 꽉 채움
            .padding(16.dp)           // 안쪽 여백
            .background(Color.Yellow) // 배경색
            .border(1.dp, Color.Black) // 테두리
            .clickable { }            // 클릭 가능
    )
}
```

---

# 상태 관리 (State)

```kotlin
@Composable
fun CounterApp() {
    // remember: 리컴포지션에서 상태 유지
    // mutableStateOf: 상태 변경 시 UI 자동 업데이트
    var count by remember { mutableStateOf(0) }

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(text = "$count", fontSize = 48.sp)
        Spacer(modifier = Modifier.height(16.dp))
        Row {
            Button(onClick = { count-- }) {
                Text("-")
            }
            Spacer(modifier = Modifier.width(16.dp))
            Button(onClick = { count++ }) {
                Text("+")
            }
        }
    }
}
```

---

# 앱 실행

| 방법 | 설명 |
|------|------|
| 에뮬레이터 | AVD Manager에서 생성 후 실행 |
| 실기기 | USB 디버깅 활성화 후 연결 |
| ▶ Run | Shift+F10 또는 Run 버튼 |

```
실기기 USB 디버깅 활성화:
설정 → 개발자 옵션 → USB 디버깅 ON
(개발자 옵션: 설정 → 휴대전화 정보 → 빌드번호 7번 탭)
```

{% assign c-category = 'kotlin' %}
{% assign c-tag = 'lecture-kotlin' %}
{% include /custom-ref.html %}
