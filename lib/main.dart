import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/screens/detail_alarm_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'package:workmanager/workmanager.dart';

// 백그라운드 작업을 위한 콜백 함수
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
  // 여기에 자정 무렵에 수행할 작을 구현합니다.
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

    // 데이터 변경 알림

    debugPrint(
        "end of updateMedication in _performMidnightTask-----------------------------------");
  }

  // 모든 업데이트가 완료된 후 최신 데이터 로드(최신화된 데이터를 가지고 후속 작업을 수행하고싶다면 이용하자.)
  // medications = await StorageService().loadMedications();

  // 예: 데이터 초기화, 일일 보고서 생성 등
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
    "periodicTask",
    "periodicTask",
    frequency: const Duration(minutes: 15),
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
          create: (_) {
            final provider = MedicationProvider()..loadMedications();
            provider.startPeriodicRefresh(); // 주기적 새로고침 시작
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: '약 복용 알림',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LifecycleWatcher(
          child: HomeScreen(),
        ),
        routes: {
          '/detail_alarm': (context) => const DetailAlarmScreen(),
        },
      ),
    );
  }
}

class LifecycleWatcher extends StatefulWidget {
  final Widget child;

  const LifecycleWatcher({super.key, required this.child});

  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 데이터 새로고침
      Provider.of<MedicationProvider>(context, listen: false)
          .refreshMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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

  void updateMedication(Medication medication, Medication nextMedication,
      int originMedicationBaseScheduleId) async {
    debugPrint(
        "updateMedication in main.dart-----------------------------------");
    debugPrint("nextMedication in main.dart: $nextMedication");
    debugPrint(
        "originMedicationBaseScheduleId in main.dart: $originMedicationBaseScheduleId");

    await NotificationService()
        .cancelAndRescheduleMedicationNotifications(medication, nextMedication);
    await StorageService()
        .updateMedication(nextMedication, originMedicationBaseScheduleId);
    _medications = await StorageService().loadMedications();

    notifyListeners();
    debugPrint(
        "end of updateMedication in main.dart-----------------------------------");
  }

  void checkAllMedications() async {
    await StorageService().checkAllMedications();
    await NotificationService().checkActiveNotifications();
  }

  Future<void> refreshMedications() async {
    _medications = await StorageService().loadMedications();
    notifyListeners();
  }

  // 주기적으로 데이터를 새로고침하는 메서드
  void startPeriodicRefresh() {
    Timer.periodic(const Duration(minutes: 15), (_) {
      refreshMedications();
    });
  }

  // void update
}
