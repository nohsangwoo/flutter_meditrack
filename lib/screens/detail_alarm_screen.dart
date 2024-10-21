import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:meditrack/models/medication.dart';
import 'package:meditrack/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class DetailAlarmScreen extends StatefulWidget {
  const DetailAlarmScreen({super.key});

  @override
  State<DetailAlarmScreen> createState() => _DetailAlarmScreenState();
}

class _DetailAlarmScreenState extends State<DetailAlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String payloadString =
        ModalRoute.of(context)!.settings.arguments as String;
    final Map<String, dynamic> payload = jsonDecode(payloadString);
    final medicationProvider = Provider.of<MedicationProvider>(context);

    final medication = medicationProvider.medications.firstWhere(
      (element) => element.baseScheduleId == payload['baseScheduleId'],
      orElse: () => Medication.empty(),
    );
    bool isTodayMedicationTaken = medication.hasTakenMedicationTodayDate ==
        Medication.dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("약 복용 알림",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor:
            isTodayMedicationTaken ? Colors.green[700] : Colors.white,
        foregroundColor: isTodayMedicationTaken ? Colors.white : Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isTodayMedicationTaken
                ? [Colors.green[100]!, Colors.green[200]!]
                : [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isTodayMedicationTaken
                            ? Colors.green[800]
                            : Colors.blue[800],
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  color:
                      isTodayMedicationTaken ? Colors.green[50] : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '복용 시간',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isTodayMedicationTaken
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(medication.time),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: isTodayMedicationTaken
                                    ? Colors.green[800]
                                    : Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animation.value * 0.1),
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isTodayMedicationTaken
                                ? Icons.check_circle
                                : Icons.medication,
                            size: 32,
                          ),
                          onPressed: !isTodayMedicationTaken
                              ? () async {
                                  _controller.forward();
                                  const uuid = Uuid();
                                  final originMedicationBaseScheduleId =
                                      payload['baseScheduleId'];
                                  final nextBaseScheduleId =
                                      uuid.v4().hashCode & 0x7FFFFFFF;
                                  final nextMedication = Medication(
                                    name: medication.name,
                                    time: medication.time,
                                    baseScheduleId: nextBaseScheduleId,
                                    hasTakenMedicationToday: true,
                                    hasTakenMedicationTodayDate:
                                        Medication.dateOnly(DateTime.now()),
                                  );
                                  medicationProvider.updateMedication(
                                      medication,
                                      nextMedication,
                                      originMedicationBaseScheduleId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${medication.name} 복용 확인됨. 다음 날 알림이 재설정되었습니다.')),
                                  );
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  _controller.reverse();
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTodayMedicationTaken
                                ? Colors.green[700]
                                : Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          label: Text(
                            !isTodayMedicationTaken ? "약 복용 확인" : "오늘 복용 완료",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animation.value * 0.2),
                        child: Icon(
                          isTodayMedicationTaken
                              ? Icons.check_circle
                              : Icons.medication_liquid,
                          size: 120,
                          color: isTodayMedicationTaken
                              ? Colors.green
                              : Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString();

    return '$period $formattedHour:$minute';
  }
}
