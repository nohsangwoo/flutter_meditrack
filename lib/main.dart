import 'package:flutter/material.dart';
import 'package:meditrack/providers/medication_provider.dart';
import 'package:meditrack/screens/detail_alarm_screen.dart';
import 'package:meditrack/widgets/with_lifecycle_watcher.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
// import 'services/background_service.dart';  // 필요시 주석 해제

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  await StorageService().initialize();

  // Workmanager 초기화 (필요시 주석 해제)
  // await initializeBackgroundService();

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
        // 여기에 다른 Provider들을 추가할 수 있습니다.
      ],
      child: MaterialApp(
        title: '약 복용 알림',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const WithLifecycleWatcher(
          child: HomeScreen(),
        ),
        routes: {
          '/detail_alarm': (context) => const DetailAlarmScreen(),
        },
      ),
    );
  }
}
