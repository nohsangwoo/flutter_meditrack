import 'package:flutter/material.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/screens/detail_alarm_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'package:workmanager/workmanager.dart';

// 백그라운드 작업을 위한 콜백 함수
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("백그라운드 작업 실행: ${DateTime.now()}-------------------");

    // StorageService 초기화
    await StorageService().initialize();

    // 약물 정보 불러오기
    List<Medication> medications = await StorageService().loadMedications();

    // 약물 정보 사용 예시
    for (var medication in medications) {
      debugPrint(
          "약물 이름: ${medication.name}, 복용 시간: ${medication.time}, hasTakenMedicationToday: ${medication.hasTakenMedicationToday}, hasTakenMedicationTodayDate: ${medication.hasTakenMedicationTodayDate}");
      // 여기에서 필요한 작업을 수행합니다.
      // 예: 알림 확인, 복용 여부 업데이트 등
      // #1. 약 복용확인이 체크된 경우
      if (medication.hasTakenMedicationToday == true) {
        // Medication.dateOnly(DateTime.now())) {
        // medication.markAsTakenToday();
        // await StorageService().saveMedications(medications);
        debugPrint("약 복용만 체크된 경우: $medication");
        // #2. 체크된 약먹은 날이 오늘이거나 이전날인경우
        if (medication.hasTakenMedicationTodayDate != null &&
            medication.hasTakenMedicationTodayDate!.isBefore(
                Medication.dateOnly(DateTime.now())
                    .add(const Duration(days: 1)))) {
          // 오늘 또는 이전에 약을 복용한 경우의 처리
          debugPrint("오늘 또는 이전에 복용 확인된 약물입니다.: $medication");
          // 여기에 필요한 로직을 추가하세요
        } else {
          // 약을 복용하지 않았거나, 미래 날짜인 경우의 처리
          debugPrint("아직 복용하지 않았거나 미래 날짜의 약물입니다.: $medication");
          // 여기에 필요한 로직을 추가하세요
        }
      }
    }

    debugPrint("end of background work-------------------");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  await StorageService().initialize();

  // Workmanager 초기화
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // 1분마다 실행되는 주기적 작업 등록
  await Workmanager().registerPeriodicTask(
    "15",
    "simplePeriodicTask",
    frequency: const Duration(minutes: 1),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicationProvider()..loadMedications(),
        ),
      ],
      child: MaterialApp(
        title: '약 복용 알림',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const HomeScreen(),
        routes: {
          '/': (context) => const HomeScreen(),
          '/detail_alarm': (context) => const DetailAlarmScreen(),
        },
      ),
    );
  }
}

class MedicationProvider extends ChangeNotifier {
  // provider와 영구 저장을 위한 shared_preferences를 연동하기 위한 내용들

  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    StorageService().saveMedications(_medications);
    await NotificationService().scheduleMedicationNotification(medication);
    notifyListeners();
  }

  void loadMedications() async {
    _medications = await StorageService().loadMedications();
    for (var medication in _medications) {
      await NotificationService().scheduleMedicationNotification(medication);
    }
    notifyListeners();
  }

  void deleteMedication(Medication medication) async {
    _medications.remove(medication);
    await StorageService().saveMedications(_medications);
    await NotificationService().cancelNotification(medication.baseScheduleId);
    notifyListeners();
  }

  void deleteAllMedications() async {
    _medications = [];
    await StorageService().deleteAllMedications();
    await NotificationService().cancelAllNotifications();
    notifyListeners();
  }

  void updateMedication(
      Medication nextMedication, int originMedicationBaseScheduleId) async {
    debugPrint(
        "updateMedication in main.dart-----------------------------------");
    debugPrint("nextMedication in main.dart: $nextMedication");
    debugPrint(
        "originMedicationBaseScheduleId in main.dart: $originMedicationBaseScheduleId");
    await StorageService()
        .updateMedication(nextMedication, originMedicationBaseScheduleId);
    _medications = await StorageService().loadMedications();
    await NotificationService()
        .scheduleMedicationNotification(nextMedication, isNextDay: true);
    notifyListeners();
    debugPrint(
        "end of updateMedication in main.dart-----------------------------------");
  }

  void checkAllMedications() async {
    await StorageService().checkAllMedications();
    await NotificationService().checkActiveNotifications();
  }

  // void update
}
