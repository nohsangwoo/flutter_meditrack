import 'package:flutter/material.dart';

class DetailAlarmScreen extends StatelessWidget {
  const DetailAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text("알람 상세페이지")),
      body: Center(child: Text(data.toString())),
    );
  }
}
