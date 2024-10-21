import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import '../models/medication.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final onClickNotification = BehaviorSubject<String>();

  // 반복알람 등록 및 취소시 사용되는 변수
  // 최대 반복알람 갯수
  static const int maxFollowUpNotifications = 2;

  // 반복알람의 등록되는 간격(분)
  static const int followUpIntervalMinutes = 15;

  // on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("알림이 탭되었습니다");
    if (notificationResponse.payload != null) {
      try {
        final decodedPayload = jsonDecode(notificationResponse.payload!);
        debugPrint("decodedPayload: $decodedPayload");

        final int baseScheduleId = decodedPayload['baseScheduleId'];
        final String medicationName = decodedPayload['medicationName'];
        final String scheduledDate = decodedPayload['scheduledDate'];

        // final String dosage = decodedPayload['dosage'];
        print('약 이름: $medicationName');
        print('예약 시간: $scheduledDate');
        print('baseScheduleId: $baseScheduleId');
        // print('복용량: $dosage');

        // 여기서 필요한 추가 처리를 수행할 수 있습니다.
        onClickNotification.add(notificationResponse.payload!);
      } catch (e) {
        print('페이로드 디코딩 오류: $e');
      }
    }
  }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대로 설정

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
    await _requestPermissions();

    // 활성화된 알람 확인 및 디버그 출력
    await checkActiveNotifications();
  }

  // 권한 요청 메서드
  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS 권한 요청 (필요한 경우)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleMedicationNotification(Medication medication,
      {bool isNextDay = false}) async {
    final tz.TZDateTime scheduledDate =
        _nextInstanceOfTime(medication.time, isNextDay: isNextDay);

    debugPrint(
        'scheduleMedicationNotification-----------------------------------');
    debugPrint('scheduledDate: $scheduledDate');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      '약 복용 알림',
      channelDescription: '약 복용 시간을 알려줍니다',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final payload = jsonEncode({
      'baseScheduleId': medication.baseScheduleId,
      'medicationName': medication.name,
      'scheduledDate': scheduledDate.toIso8601String(),
    });

    // 매일 반복되는 알람 설정
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medication.baseScheduleId,
      '약 복용 시간',
      '${medication.name} 복용 시간입니다',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    // 1분 간격 알림을 설정하는 새로운 메서드 호출
    await _scheduleFollowUpNotifications(
        medication, scheduledDate, platformChannelSpecifics,
        isNextDay: isNextDay);

    debugPrint(
        'end of scheduleMedicationNotification-----------------------------------');
  }

  // 새로운 메서드: 반복 알림 설정
  Future<void> _scheduleFollowUpNotifications(Medication medication,
      tz.TZDateTime scheduledDate, NotificationDetails platformChannelSpecifics,
      {bool isNextDay = false}) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Duration timeUntilScheduled = scheduledDate.difference(now);

// 기본적으로는 매일 반복이다가 isNextDay의 경우에는
    if (timeUntilScheduled.isNegative || isNextDay) {
      // 이미 지난 시간이면 다음 날로 설정... 하고싶은데 지금은 네이티브가 아니라 안됨.
      // 그리고 isNextDay가 true일때도 다음 날로 설정

      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    for (int i = 1; i <= maxFollowUpNotifications; i++) {
      final tz.TZDateTime followUpTime =
          scheduledDate.add(Duration(minutes: followUpIntervalMinutes * i));
      final payload = jsonEncode({
        'baseScheduleId': medication.baseScheduleId,
        'medicationName': medication.name,
        'scheduledDate': followUpTime.toIso8601String(),
      });
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        medication.baseScheduleId + i,
        '약 복용 알림',
        '${medication.name} 복용을 잊지 마세요',
        followUpTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time, {bool isNextDay = false}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (isNextDay) {
      // 무조건 다음 날로 설정
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    } else if (scheduledDate.isBefore(now)) {
      // 현재 시간보다 이전이면 다음 날로 설정
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('scheduledDate in nextInstanceOfTime: $scheduledDate');

    return scheduledDate;
  }

  Future<void> hardcodingScheduleMedicationNotificationForTest() async {
    // set yy mm dd and time for pm 10:00
    tz.TZDateTime settingTime = tz.TZDateTime(tz.local, 2024, 10, 18, 11, 2);
// 2024-01-22 00:00:00.000Z

    debugPrint("settingTime: $settingTime");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      '약 복용 알림',
      channelDescription: '약 복용 시간을 알려줍니다',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '약 복용 시간',
      '젤잔즈 테스트 약 복용 시간입니다',
      settingTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: settingTime.toIso8601String(),
    );
  }

  Future<void> cancelNotification(int baseScheduleId) async {
    for (int i = 0; i <= maxFollowUpNotifications; i++) {
      await _flutterLocalNotificationsPlugin.cancel(baseScheduleId + i);
    }
  }

  // 새 메서드 추가
  Future<void> checkActiveNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint(
        'checkActiveNotifications in notification service---------------');
    debugPrint('활성화된 알람 수: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      debugPrint('알람 ID: ${notification.id}');
      debugPrint('알람 제목: ${notification.title}');
      debugPrint('알람 본문: ${notification.body}');
      debugPrint('payload: ${notification.payload}');
    }
    debugPrint(
        'end of checkActiveNotifications in notification service---------------');
  }

  // 새로운 메서드 추가
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('모든 알람이 취소되었습니다.');
  }

  Future<void> scheduleAllDayNotifications(int minute) async {
    for (int hour = 0; hour < 24; hour++) {
      await scheduleDailyNotification(hour, minute);
    }
    debugPrint('24시간 모든 알림이 $minute분에 설정되었습니다.');
  }

  // to schedule a local notification
  Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        title,
        body,
        tz.TZDateTime.now(tz.local)
            .add(const Duration(seconds: 5)), // 5초 에 알림 예약
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channel 3', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String scheduleInfo =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    final int notificationId = int.parse(
        '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_notification_channel',
      '일 알림',
      channelDescription: '매일 정해진 시간에 알림을 보냅니다',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '정기 알림',
      '$scheduleInfo 알림입니다',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload:
          'daily_notification|$scheduleInfo|${scheduledDate.toIso8601String()}',
    );

    debugPrint('$scheduleInfo 알림이 설정되었습니다. 다음 알림 시간: $scheduledDate');
  }

  Future<void> cancelMedicationNotifications(int medicationId) async {
    // 초기 알림 취소
    await _flutterLocalNotificationsPlugin.cancel(medicationId);
    // 반복 알림 취소
    await _flutterLocalNotificationsPlugin.cancel(medicationId + 1);
  }

  Future<void> cancelAndRescheduleMedicationNotifications(
      Medication medication, Medication nextMedication) async {
    // 현재 알림 취소
    await cancelNotification(medication.baseScheduleId);

    debugPrint("current medication: $medication");
    debugPrint("nextMedication: $nextMedication");

    await scheduleMedicationNotification(nextMedication, isNextDay: true);
  }
}
