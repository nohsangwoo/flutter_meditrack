# meditrack

A personalized medication reminder app that helps users who often forget to take their medications on time. This simple yet effective tool sends customized alerts to ensure timely medication intake, making it highly useful for those who struggle with remembering their medication schedules.

# android setting reference

- android/build.gradle
- android/app/build.gradle
- android/app/src/main/AndroidManifest.xml

# ios setting reference

- ref: https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/ios/Runner/AppDelegate.swift

- ios/Runner/AppDelegate.swift

# modules

- flutter_local_notifications - ref: https://pub.dev/packages/flutter_local_notifications
- flutter timezone - ref: https://pub.dev/packages/timezone
- rxdart - ref: https://pub.dev/packages/rxdart

# issue - 1

```
Failed to build iOS app
Could not build the precompiled application for the device.
Error (Xcode): double-quoted include "ActionEventSink.h" in framework header, expected angle-bracketed instead
/Users/nohsangwoo/Documents/project/meditrack/ios/Pods/Target%20Support%20Files/flutter_local_notifications/flutter_local_notifications-umbrella.h:12:8

Error (Xcode): 'Flutter/Flutter.h' file not found
/Users/nohsangwoo/.pub-cache/hosted/pub.dev/flutter_local_notifications-17.2.3/ios/Classes/ActionEventSink.h:12:8

Error (Xcode): (fatal) could not build module 'flutter_local_notifications'
/Users/nohsangwoo/Library/Developer/Xcode/DerivedData/Runner-eyugalixibunstcaofnvzpdcrcru/Build/Intermediates.noindex/Pods.build/Debug-iphoneos/flutter_local_notifications.build/VerifyModule/flutter_local_notifications_objective-c_arm64-apple-ios12.0_gnu11/Test/Test.framework/Headers/Test.h:0:8

Error (Xcode): (fatal) could not build module 'Test'
/Users/nohsangwoo/Library/Developer/Xcode/DerivedData/Runner-eyugalixibunstcaofnvzpdcrcru/Build/Intermediates.noindex/Pods.build/Debug-iphoneos/flutter_local_notifications.build/VerifyModule/flutter_local_notifications_objective-c_arm64-apple-ios12.0_gnu11/Test/Test.m:0:8
2

Error launching application on Nohs iphone.
```

![alt text](image.png)

# issue - 2

timezone이 일반적으로 UTC로 설정되어 있어서 한국 시간대로 설정해줘야함.

```
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대로 설정
```

# todos

- 영구저장소에 저장된 기록이 실제로는 파일로 저장된 상태인데 앱을껐다 켜면 provider와 연동이 안됨. ✅
- 알람을 클릭하면 알람 상세페이지로 이동 후 알람이 꺼지는 기능 추가 ✅
- 알람이 꺼지기전까지 5분주기로 계속 알람이 울리게 설정.

- 아이콘 추가 ✅
- app 배포 준비

- 지우는 기능 먼저 구현
- 그다음 알람 재설정 기능 구현(지우고 다시 재설정 하는 형식이라 지우는 기능 먼저 구현해야함)
  (target: cancelAndRescheduleMedicationNotifications in notification_service.dart)

# workmanager를 이용하여 일정시간마다 체크해서 매일 알람을 재설정하는 기능 구현하기

- provider로 등록된 모든 알람에서 오늘 복용체크가 완료됐는지 확인하는 변수를 확인한다.
  (변수이름은 hasTakenMedicationToday)
- 만약 오늘 복용체크가 완료됐다면 알람을 재설정하고 완료되지 않았다면 알람을 그대로 둔다
  재설정하는 알람은 반복되는 알람인 \_scheduleFollowUpNotifications 메서드를 조건에따라 재설정한다.
