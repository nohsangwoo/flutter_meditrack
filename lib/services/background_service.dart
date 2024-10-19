import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/services/notification_service.dart';
import 'package:meditrack/services/storage_service.dart';
import 'package:uuid/uuid.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("백그라운드 작업 실행: ${DateTime.now()}-------------------");

    switch (task) {
      case 'periodicTask':
        await _performPeriodicTask();
        break;
    }

    debugPrint("end of background work-------------------");
    return Future.value(true);
  });
}

Future<void> _performPeriodicTask() async {
  final now = DateTime.now();
  if (now.hour == 0 && now.minute < 15 || now.hour == 23 && now.minute >= 45) {
    await _performMidnightTask();
  }
}

Future<void> _performMidnightTask() async {
  // 여기에 자정 무렵에 수행할 작업을 구현합니다.
  print('자정 작업 수행 중: ${DateTime.now()}');

  // StorageService 초기화
  await StorageService().initialize();

  // 약물 정보 불러오기
  List<Medication> medications = await StorageService().loadMedications();

  // 약물 정보 사용 예시
  for (var medication in medications) {
    const uuid = Uuid();

    final originMedicationBaseScheduleId = medication.baseScheduleId;
    final nextBaseScheduleId = uuid.v4().hashCode & 0x7FFFFFFF;

    final nextMedication = Medication(
      name: medication.name,
      time: medication.time,
      baseScheduleId: nextBaseScheduleId,
      hasTakenMedicationToday: false,
      hasTakenMedicationTodayDate: null,
    );

    debugPrint(
        "updateMedication in _performMidnightTask-----------------------------------");
    debugPrint("nextMedication in _performMidnightTask: $nextMedication");
    debugPrint(
        "originMedicationBaseScheduleId in _performMidnightTask: $originMedicationBaseScheduleId");

    // StorageService를 사용하여 데이터 업데이트
    await StorageService()
        .updateMedication(nextMedication, originMedicationBaseScheduleId);

    // NotificationService를 사용하여 알림 업데이트
    await NotificationService()
        .cancelAndRescheduleMedicationNotifications(medication, nextMedication);

    debugPrint(
        "end of updateMedication in _performMidnightTask-----------------------------------");
  }
}

Future<void> initializeBackgroundService() async {
  // Workmanager 초기화
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // 15분마다 실행되는 주기적 작업 등록
  await Workmanager().registerPeriodicTask(
    "periodicTask",
    "periodicTask",
    frequency: const Duration(minutes: 15),
  );
}
