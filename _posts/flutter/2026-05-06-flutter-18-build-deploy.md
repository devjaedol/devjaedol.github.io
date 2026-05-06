---
title: "[Flutter] 18. 빌드와 배포 - APK, App Store"
categories: 
    - flutter
tags: 
    [flutter, dart, 중급, 'lecture-flutter']
toc : true
toc_sticky  : true    
---

Flutter 앱을 빌드하고 스토어에 배포하는 과정을 배웁니다.

# 빌드 전 준비

## 앱 아이콘 설정

```yaml
# pubspec.yaml
dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # 1024x1024 권장
```

```bash
flutter pub run flutter_launcher_icons
```

## 스플래시 화면

```yaml
# pubspec.yaml
dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#ffffff"
  image: assets/splash.png
  android: true
  ios: true
```

```bash
flutter pub run flutter_native_splash:create
```

---

# Android 빌드

## 1. 서명 키 생성

```bash
# 키스토어 생성 (최초 1회)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

## 2. 키 설정

```properties
# android/key.properties (새로 생성, .gitignore에 추가!)
storePassword=비밀번호
keyPassword=비밀번호
keyAlias=upload
storeFile=경로/upload-keystore.jks
```

## 3. build.gradle 설정

```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    defaultConfig {
        applicationId "com.example.myapp"  // 고유 패키지명
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 4. APK / AAB 빌드

```bash
# APK 빌드 (직접 설치용)
flutter build apk --release

# AAB 빌드 (Google Play 업로드용, 권장)
flutter build appbundle --release
```

빌드 결과:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 5. Google Play 배포

1. [Google Play Console](https://play.google.com/console){:target="_blank"} 접속
2. 개발자 계정 등록 ($25 일회성)
3. 앱 만들기 → 정보 입력
4. AAB 파일 업로드
5. 스토어 등록 정보 작성 (스크린샷, 설명 등)
6. 심사 제출

---

# iOS 빌드

## 1. 사전 요구사항

- Mac 필수
- Xcode 설치
- Apple Developer 계정 ($99/년)

## 2. Xcode 설정

```bash
# iOS 폴더에서 Pod 설치
cd ios
pod install
cd ..
```

Xcode에서 `ios/Runner.xcworkspace` 열기:
- Bundle Identifier 설정 (예: `com.example.myapp`)
- Team 선택 (Apple Developer 계정)
- Signing & Capabilities 설정

## 3. 빌드

```bash
# iOS 빌드
flutter build ios --release

# IPA 파일 생성 (배포용)
flutter build ipa
```

## 4. App Store 배포

1. Xcode → Product → Archive
2. Distribute App → App Store Connect
3. [App Store Connect](https://appstoreconnect.apple.com){:target="_blank"} 에서 앱 정보 입력
4. 심사 제출 (보통 1~3일 소요)

---

# Web 빌드

```bash
# 웹 빌드
flutter build web

# 결과: build/web/ 폴더
# 이 폴더를 웹 서버에 배포
```

배포 옵션:
- Firebase Hosting
- GitHub Pages
- Netlify
- Vercel

```bash
# Firebase Hosting 예시
firebase init hosting
firebase deploy
```

---

# 빌드 최적화 팁

| 항목 | 방법 |
|------|------|
| 앱 크기 줄이기 | `flutter build apk --split-per-abi` |
| 난독화 | `--obfuscate --split-debug-info=./debug-info` |
| 미사용 코드 제거 | Tree shaking (자동) |
| 이미지 최적화 | WebP 형식 사용 |
| 패키지 정리 | 미사용 패키지 제거 |

```bash
# 최적화된 빌드 명령어
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./debug-info
```

---

# 버전 관리

```yaml
# pubspec.yaml
version: 1.2.3+4
#        │ │ │ └── 빌드 번호 (versionCode, 매 업로드마다 증가)
#        │ │ └──── 패치 (버그 수정)
#        │ └────── 마이너 (기능 추가)
#        └──────── 메이저 (큰 변경)
```

{% assign c-category = 'flutter' %}
{% assign c-tag = 'lecture-flutter' %}
{% include /custom-ref.html %}
