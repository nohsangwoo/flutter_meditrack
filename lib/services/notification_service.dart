import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import '../models/medication.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final onClickNotification = BehaviorSubject<String>();

  // on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    // push같은 기능임.
    print("notification tapped");
    onClickNotification.add(notificationResponse.payload!);
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

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted =
        await androidImplementation?.requestNotificationsPermission();
    debugPrint('알림 권한 요청 결과: $granted');

    final bool? result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    debugPrint('iOS 알림 권한 요청 결과: $result');
  }

  Future<void> scheduleMedicationNotification(Medication medication) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("현재 시간 (tz.local): $now");
    print("현재 시간 (DateTime.now()): ${DateTime.now()}");
    print("로컬 시간대: ${tz.local}");
    print("약물 정보: $medication");

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      medication.time.hour,
      medication.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("예약된 알림 시간: $scheduledDate");

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
      medication.hashCode,
      '약 복용 시간',
      '${medication.name} 복용 시간입니다',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: scheduledDate.toIso8601String(),
    );
  }

  Future<void> hardcodingScheduleMedicationNotificationForTest() async {
    // set yy mm dd and time for pm 10:00
    tz.TZDateTime settingTime = tz.TZDateTime(tz.local, 2024, 10, 18, 23, 23);
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

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 새로운 메서드 추가
  Future<void> checkActiveNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    debugPrint('활성화된 알람 수: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      final List<String> payloadParts = notification.payload?.split('|') ?? [];
      final String notificationType =
          payloadParts.isNotEmpty ? payloadParts[0] : '알 수 없음';
      final String scheduleInfo =
          payloadParts.length > 1 ? payloadParts[1] : '알 수 없음';
      String scheduledTime =
          payloadParts.length > 2 ? payloadParts[2] : '알 수 없음';

      debugPrint('알람 ID: ${notification.id}');
      debugPrint('알람 제목: ${notification.title}');
      debugPrint('알람 본문: ${notification.body}');
      debugPrint('알림 유형: $notificationType');
      debugPrint('스케줄 정보: $scheduleInfo');
      debugPrint('예정된 시간: $scheduledTime');
      debugPrint('---');
    }
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
            .add(const Duration(seconds: 5)), // 5초 후에 알림 예약
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
      '일일 알림',
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
}
