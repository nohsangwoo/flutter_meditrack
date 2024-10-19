import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/providers/medication_provider.dart';
import 'package:meditrack/screens/detail_alarm_screen.dart';
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
  LifecycleWatcherState createState() => LifecycleWatcherState();
}

class LifecycleWatcherState extends State<LifecycleWatcher>
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
