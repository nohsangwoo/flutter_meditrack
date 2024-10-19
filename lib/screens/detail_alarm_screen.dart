import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:meditrack/main.dart';
import 'package:meditrack/services/notification_service.dart';
import 'package:provider/provider.dart';

class DetailAlarmScreen extends StatelessWidget {
  const DetailAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String payloadString =
        ModalRoute.of(context)!.settings.arguments as String;
    final Map<String, dynamic> payload = jsonDecode(payloadString);

    final medicationProvider = Provider.of<MedicationProvider>(context);

    final medication = medicationProvider.medications.firstWhere(
      (element) => element.hashCode == payload['id'],
    );

    debugPrint("specific medication: $medication");

    return Scaffold(
      appBar: AppBar(title: const Text("알람 상세페이지")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('알림 ID: ${payload['id']}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('약 이름: ${payload['medicationName']}',
                style: Theme.of(context).textTheme.titleMedium),
            // Text('복용량: ${payload['dosage']}',
            //     style: Theme.of(context).textTheme.titleMedium),
            Text('예약 시간: ${payload['scheduleTime']}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('예약된 날짜: ${payload['scheduledDate']}',
                style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cancel),
                onPressed: () async {
                  // await NotificationService()
                  //     .cancelNotification(medication.hashCode);
                  medicationProvider.deleteMedication(medication);
                },
                label: const Text("Remove all Notifications"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
