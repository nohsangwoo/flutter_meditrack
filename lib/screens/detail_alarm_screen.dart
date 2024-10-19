import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:meditrack/main.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DetailAlarmScreen extends StatelessWidget {
  const DetailAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String payloadString =
        ModalRoute.of(context)!.settings.arguments as String;
    final Map<String, dynamic> payload = jsonDecode(payloadString);

    final medicationProvider = Provider.of<MedicationProvider>(context);

    print('payload: $payload');

    print('medicationProvider: ${medicationProvider.medications}');

    // final medicationScheduleId = payload['id'];

    // final medicationScheduleId

    final medication = medicationProvider.medications.firstWhere(
      (element) => element.baseScheduleId == payload['baseScheduleId'],
      orElse: () => Medication.empty(),
    );
    debugPrint("specific medication in detail_alarm_screen: $medication");

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
            Text('baseScheduleId: ${payload['baseScheduleId']}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(
                'hasTakenMedicationToday: ${payload['hasTakenMedicationToday']}',
                style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  const uuid = Uuid();

                  final originMedicationBaseScheduleId =
                      payload['baseScheduleId'];
                  final nextBaseScheduleId = uuid.v4().hashCode & 0x7FFFFFFF;

                  final nextMedication = Medication(
                    name: medication.name,
                    time: medication.time,
                    baseScheduleId: nextBaseScheduleId,
                  );

                  print(
                      "originMedicationBaseScheduleId in detail_alarm_screen: $originMedicationBaseScheduleId");
                  print(
                      "nextMedication in detail_alarm_screen: $nextMedication");

                  await NotificationService()
                      .cancelAndRescheduleMedicationNotifications(
                          medication, nextMedication);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${medication.name} 복용 확인됨. 다음 날 알림이 재설정되었습니다.')),
                  );
                  medicationProvider.updateMedication(
                      nextMedication, originMedicationBaseScheduleId);
                  Navigator.of(context).pop();
                },
                label: const Text("약 복용 확인"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
