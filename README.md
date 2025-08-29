# MediConnect - 한국 의료관광 플랫폼 모바일 앱

한국의 병원 정보를 제공하고 의료관광을 지원하는 Flutter 모바일 앱입니다.

## 🎯 주요 기능

### ✅ 구현 완료
- **인증 시스템**: Supabase Auth를 사용한 로그인/회원가입
- **모던한 UI**: Liquid Glass 컨셉의 iOS 스타일 디자인
- **홈 화면**: 병원 검색, 추천 병원, 병원 목록
- **바텀 네비게이션**: 5개 탭 (홈, 프로모션, 예약내역, 광고문의, 내정보)
- **프로필 관리**: 사용자 정보 및 로그아웃 기능
- **반응형 애니메이션**: 부드러운 전환 효과

### 🚧 구현 예정
- 병원 상세 정보
- 프로모션 목록 및 상세
- 예약 시스템
- 리뷰 작성 및 관리
- 다국어 지원 (한국어, 영어, 중국어, 일본어)
- 지도 연동
- 결제 시스템

## 🛠 기술 스택

- **Framework**: Flutter 3.5.3+
- **State Management**: Riverpod
- **Backend**: Supabase (인증, 데이터베이스)
- **UI Design**: Material 3 + Custom Glass Effects
- **HTTP Client**: Dio
- **폰트**: Google Fonts (Noto Sans)
- **로컬 저장소**: SharedPreferences

## 📱 화면 구성

### 1. 인증 화면
- 모던한 글래스 모피즘 디자인
- 로그인/회원가입 전환
- 이메일 유효성 검사
- 부드러운 애니메이션 효과

### 2. 홈 화면
- 병원 검색 기능
- 전문과목 빠른 필터
- 추천 병원 가로 스크롤
- 전체 병원 리스트

### 3. 바텀 네비게이션
- 홈: 병원 검색 및 목록
- 프로모션: 할인 정보 (구현 예정)
- 예약내역: 내 예약 관리 (구현 예정)
- 광고문의: 병원/에이전시 문의 (구현 예정)
- 내정보: 프로필 및 설정

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.5.3+
- Dart 3.0+
- iOS 11.0+ / Android API 21+

### 설치 및 실행

1. **의존성 설치**
```bash
flutter pub get
```

2. **iOS 시뮬레이터 실행**
```bash
flutter run
```

3. **Android 에뮬레이터 실행**
```bash
flutter run -d android
```

## 🔧 환경 설정

### Supabase 설정
`lib/constants/app_config.dart`에서 Supabase 설정을 확인하세요:

```dart
class AppConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 테스트 계정
앱을 테스트하려면 다음 단계를 따르세요:

1. 회원가입 화면에서 이메일과 비밀번호 입력
2. 이메일 확인 (개발 모드에서는 자동 확인)
3. 로그인하여 메인 화면 접근

## 🎨 디자인 시스템

### 컬러 팔레트
- **Primary**: #007AFF (iOS 블루)
- **Success**: #34C759
- **Warning**: #FF9500
- **Error**: #FF3B30

### 글래스 모피즘 효과
- BackdropFilter를 사용한 블러 효과
- 반투명 배경과 테두리
- 그라데이션을 통한 입체감
- 부드러운 그림자 효과

### 타이포그래피
- **폰트**: Noto Sans (한글 지원)
- **크기**: 12px ~ 32px
- **굵기**: 400 (Regular) ~ 700 (Bold)

## 📁 프로젝트 구조

```
lib/
├── constants/          # 앱 상수 및 설정
│   └── app_config.dart
├── screens/           # 화면 파일들
│   ├── auth/          # 인증 관련 화면
│   └── main/          # 메인 앱 화면들
├── widgets/           # 재사용 가능한 위젯
│   └── glass_container.dart
├── services/          # API 및 서비스 로직
├── models/           # 데이터 모델
├── providers/        # 상태 관리 (Riverpod)
└── main.dart         # 앱 진입점
```

## 🔗 관련 문서

- [Flutter 개발 가이드](../medik-project/FLUTTER_DEVELOPMENT_GUIDE.md)
- [데이터베이스 스키마](../medik-project/prisma/schema.prisma)
- [Supabase 문서](https://supabase.com/docs)
- [Riverpod 문서](https://riverpod.dev/)

## 🐛 문제 해결

### 일반적인 문제

1. **패키지 설치 오류**
```bash
flutter clean
flutter pub get
```

2. **iOS 빌드 오류**
```bash
cd ios
pod install
cd ..
flutter run
```

3. **Android 빌드 오류**
- Android Studio에서 SDK 버전 확인
- `android/app/build.gradle`에서 minSdkVersion 확인

## 📞 지원

문제가 발생하거나 질문이 있으시면:
- 이슈 생성하여 문의
- 개발팀에 직접 연락

## 📄 라이선스

이 프로젝트는 개인/상업적 사용을 위한 것입니다.



# 버전업은 pubspec.yaml 파일의 version 값을 변경하고, 버전 번호를 증가시키세요.

# 버전 번호는 다음과 같은 형식으로 작성해야 합니다:

# 1.0.0+1

# 1.0.1+2

# 1.1.0+3

# 1.1.1+4

# 버전 + 빌드 번호

버전 변경 후 

flutter clean
flutter pub get
flutter build ios



# android

1. 수정
2. pubspec.yaml 파일의 version 값을 변경하고, 버전 번호를 증가시키세요.
3. flutter clean
4. flutter build appbundle
5. flutter build appbundle --release --obfuscate --split-debug-info=build/symbols 
(경고 해결)

6. 번들된 파일을 새버전으로 게시하여 검사


7. 에뮬레이터 실행 후 
# 그냥 플러터 실행
flutter run  
flutter run -d (디버깅? 디버그 모드?)
flutter run -d 00008130-0004543201F0001C (마지막은 아이디 필요함)

# 무수히 많은 flutter E/FrameEvents( 5424): updateAcquireFence: Did not find frame. 로그 안보이게
flutter run | grep -v "updateAcquireFence"
