import 'package:flutter/material.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/screens/detail_alarm_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions(); // 권한 요청 추가
  await StorageService().initialize();
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
    await NotificationService().cancelNotification(medication.hashCode);
    notifyListeners();
  }

  void deleteAllMedications() async {
    _medications = [];
    await StorageService().deleteAllMedications();
    notifyListeners();
  }
}
