import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/providers/medication_provider.dart';

class WithLifecycleWatcher extends StatefulWidget {
  final Widget child;

  const WithLifecycleWatcher({super.key, required this.child});

  @override
  WithLifecycleWatcherState createState() => WithLifecycleWatcherState();
}

class WithLifecycleWatcherState extends State<WithLifecycleWatcher>
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
