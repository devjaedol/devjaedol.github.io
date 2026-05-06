---
title: "[Flutter] 06. Flutter 소개 및 개발환경 설치"
categories: 
    - flutter
tags: 
    [flutter, dart, 초급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter의 개념을 이해하고 개발환경을 설치합니다.

# Flutter란?

Google이 개발한 오픈소스 UI 프레임워크로, 하나의 코드로 여러 플랫폼 앱을 만들 수 있습니다.

## 지원 플랫폼

| 플랫폼 | 지원 |
|:---:|:---:|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

## Flutter vs 다른 프레임워크

| 항목 | Flutter | React Native | 네이티브 |
|:---:|:---:|:---:|:---:|
| 언어 | Dart | JavaScript | Kotlin/Swift |
| 렌더링 | 자체 엔진 (Skia) | 네이티브 브릿지 | 네이티브 |
| 성능 | 높음 | 보통 | 최고 |
| Hot Reload | ✅ | ✅ | ❌ |
| 코드 공유 | 95%+ | 80%+ | 0% |
| 학습 곡선 | 보통 | 낮음 | 높음 |

## Flutter 장점

- **Hot Reload**: 코드 수정 즉시 반영 (빠른 개발)
- **위젯 기반**: 모든 UI가 위젯으로 구성 (일관된 구조)
- **풍부한 위젯**: Material Design, Cupertino 위젯 내장
- **높은 성능**: 네이티브 코드로 컴파일

---

# 개발환경 설치

## 1. Flutter SDK 설치

### Windows

1. [Flutter SDK 다운로드](https://docs.flutter.dev/get-started/install/windows){:target="_blank"}
2. 원하는 위치에 압축 해제 (예: `C:\flutter`)
3. 환경변수 PATH에 `C:\flutter\bin` 추가

```bash
# 환경변수 설정 확인
flutter --version
```

### Mac

```bash
# Homebrew로 설치
brew install --cask flutter

# 또는 수동 설치
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# PATH 추가 (~/.zshrc)
export PATH="$HOME/development/flutter/bin:$PATH"
```

## 2. IDE 설치

### VS Code (권장 - 가벼움)

1. [VS Code 설치](https://code.visualstudio.com/){:target="_blank"}
2. Extensions에서 `Flutter` 검색 후 설치 (Dart도 자동 설치됨)

### Android Studio (풀 기능)

1. [Android Studio 설치](https://developer.android.com/studio){:target="_blank"}
2. Plugins에서 `Flutter` 검색 후 설치

## 3. 플랫폼별 추가 설정

### Android 개발

1. Android Studio에서 SDK Manager 열기
2. Android SDK 설치 (최신 버전)
3. Android Emulator 설정

### iOS 개발 (Mac만 가능)

```bash
# Xcode 설치
xcode-select --install

# CocoaPods 설치
sudo gem install cocoapods
```

## 4. 설치 확인

```bash
# 환경 진단 (문제점 자동 확인)
flutter doctor
```

정상 출력 예시:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
• No issues found!
```

> `[✗]` 표시가 있으면 해당 항목의 안내에 따라 해결합니다.

---

# 첫 프로젝트 생성

## 프로젝트 생성

```bash
# 프로젝트 생성
flutter create my_first_app

# 프로젝트 폴더로 이동
cd my_first_app

# 앱 실행
flutter run
```

## 프로젝트 구조

```
my_first_app/
├── android/          # Android 네이티브 코드
├── ios/              # iOS 네이티브 코드
├── lib/              # Dart 소스 코드 (주로 여기서 작업)
│   └── main.dart     # 앱 진입점
├── test/             # 테스트 코드
├── web/              # 웹 관련 파일
├── pubspec.yaml      # 프로젝트 설정 (의존성 관리)
└── pubspec.lock      # 의존성 잠금 파일
```

## pubspec.yaml 기본 구조

```yaml
name: my_first_app
description: 나의 첫 Flutter 앱
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

---

# 유용한 Flutter 명령어

| 명령어 | 설명 |
|--------|------|
| `flutter create 프로젝트명` | 새 프로젝트 생성 |
| `flutter run` | 앱 실행 |
| `flutter run -d chrome` | 웹 브라우저에서 실행 |
| `flutter devices` | 연결된 디바이스 목록 |
| `flutter doctor` | 환경 진단 |
| `flutter pub get` | 패키지 다운로드 |
| `flutter pub add 패키지명` | 패키지 추가 |
| `flutter clean` | 빌드 캐시 삭제 |
| `flutter build apk` | Android APK 빌드 |
| `flutter build ios` | iOS 빌드 |

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
