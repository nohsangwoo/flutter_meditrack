

# MediTrack

MediTrack은 사용자가 약 복용 일정을 잊지 않도록 돕는 개인화된 약물 알림 애플리케이션입니다. 이 간단하면서도 효과적인 도구는 사용자 맞춤형 알림을 제공하여 약 복용 시간을 정확히 지킬 수 있도록 지원하며, 특히 약 복용 스케줄을 기억하기 어려운 사용자에게 유용합니다.

## 목적

- 애플리케이션 배포 흐름을 익히기 위한 연습 프로젝트
- 약 10회 이상의 배포를 통해 배포 프로세스 숙달 목표
- 앱 심사 과정에서 발생하는 번거로운 요소 경험 및 대응

## 미리보기 (Preview)

<p float="left">
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.24.56.png" width="30%" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.25.03.png" width="30%" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.25.06.png" width="30%" />
</p>

<p float="left">
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.25.31.png" width="30%" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.25.37.png" width="30%" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2024-10-22 at 18.25.44.png" width="30%" />
</p>

## 배포 정보

- 앱 이름: 약시간 (Yaksigan)
- 배포 상태: 완료

## 설정 참고 자료

### Android 설정
- `android/build.gradle`
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`

### iOS 설정
- 참고: [flutter_local_notifications 예제](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/ios/Runner/AppDelegate.swift)
- `ios/Runner/AppDelegate.swift`

## 사용 모듈

- `flutter_local_notifications`: 로컬 알림 기능 제공 ([참고](https://pub.dev/packages/flutter_local_notifications))
- `timezone`: 시간대 관리 ([참고](https://pub.dev/packages/timezone))
- `rxdart`: 반응형 프로그래밍 지원 ([참고](https://pub.dev/packages/rxdart))

## 문제 및 해결 (Issues)

### 문제 1: iOS 빌드 실패
```
Failed to build iOS app
Error (Xcode): double-quoted include "ActionEventSink.h" in framework header, expected angle-bracketed instead
Error (Xcode): 'Flutter/Flutter.h' file not found
Error launching application on Nohs iPhone.
```
- 원인: `flutter_local_notifications` 모듈의 헤더 파일 참조 오류
- 해결: Xcode 설정 및 Podfile 점검 필요 (추가 조치 필요 시 문서화 예정)

### 문제 2: 시간대 설정
- 문제: 기본 시간대가 UTC로 설정되어 한국 시간대(Asia/Seoul)와 불일치
- 해결:
  ```dart
  tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대 설정
  ```

## 할 일 (To-Do)

- [x] 영구 저장소 데이터와 Provider 연동 문제 해결 (앱 재시작 시 데이터 유지)
- [x] 알림 클릭 시 상세 페이지로 이동 및 알림 종료 기능 추가
- [ ] 알림 종료 전 5분 주기 반복 알림 설정
- [x] 앱 아이콘 추가
- [ ] 앱 스토어 배포 준비
- [ ] 약 삭제 기능 구현
- [ ] 알림 재설정 기능 구현 (`cancelAndRescheduleMedicationNotifications` 타겟)

## 백그라운드 작업: Workmanager 활용

### 목표
- 매일 약 복용 여부(`hasTakenMedicationToday`) 확인 후 알림 재설정
- 조건에 따라 `_scheduleFollowUpNotifications` 메서드 재실행

### 참고
- [Workmanager 패키지](https://pub.dev/packages/workmanager)

### 제한사항
- Workmanager는 Android에서만 동작, iOS 미지원
- 대안: FCM(Firebase Cloud Messaging)으로 통합

## FCM 대안 전략

### 계획
1. 약 복용 버튼 클릭 시 기록 저장 및 반복 알림(`_scheduleFollowUpNotifications`) 취소
2. FCM으로 매일 자정(00:00:00)에 알림 예약
3. 취소된 반복 알림을 FCM으로 재등록

### 이유
- `flutter_local_notifications`는 알림 일시정지 기능 미지원
- 백그라운드 작업의 Android/iOS 통합 어려움
- 유지보수 효율성 증대

### 단점
- 네트워크 요청 실패 시 알림 누락 가능성

## 개선된 기획 방향

- 알림: 기존 반복 설정 유지
- 로그 기능 추가: 약 복용 시간 리스트 형식으로 하단에 기록
- 향후 필요 시 네이티브 알림 일시정지 기능 도입検討

## Flutter Native Splash 설정

### 실행 명령어
- 생성: `flutter pub run flutter_native_splash:create`
- 제거 후 재생성:
  ```
  flutter pub run flutter_native_splash:remove
  flutter pub run flutter_native_splash:create
  ```

## 개인정보 처리방침 URL 생성

- 참고: [개인정보보호 포털](https://www.privacy.go.kr/front/per/inf/perInfStep01.do)

## Keystore 생성

### 명령어
```bash
# 기본 예시
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 경로 지정 예시
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### 설정
- 생성된 Keystore 파일을 `android/app/build.gradle`에 적용 (참고 문서화 완료)

# android 배포

- flutter build appbundle
- flutter build appbundle --release

- ref: https://luvris2.tistory.com/832

빌드 파일 위치: build/app/outputs/bundle/release/app-release.aab



7. 에뮬레이터 실행 후 
# 그냥 플러터 실행
flutter run  
flutter run -d (디버깅? 디버그 모드?)
flutter run -d 00008130-0004543201F0001C (마지막은 아이디 필요함)

# 무수히 많은 flutter E/FrameEvents( 5424): updateAcquireFence: Did not find frame. 로그 안보이게
flutter run | grep -v "updateAcquireFence"