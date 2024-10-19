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
  Workmanager().executeTask((task, inputData) {
    print("백그라운드 작업 실행: ${DateTime.now()}");
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

  void addMedication(Medication medication) {
    debugPrint("for add Medication agres in main.dart: $medication");
    _medications.add(medication);
    StorageService().saveMedications(_medications);
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
    debugPrint("nextMedication in main.dart: $nextMedication");
    debugPrint(
        "originMedicationBaseScheduleId in main.dart: $originMedicationBaseScheduleId");
    await StorageService()
        .updateMedication(nextMedication, originMedicationBaseScheduleId);
    _medications = await StorageService().loadMedications();
    notifyListeners();
  }

  // void update
}
