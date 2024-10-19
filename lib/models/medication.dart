import 'package:flutter/material.dart';

class Medication {
  final String name;
  final TimeOfDay time;
  final int baseScheduleId;
  final bool? hasTakenMedicationToday;

  Medication({
    required this.name,
    required this.time,
    required this.baseScheduleId,
    this.hasTakenMedicationToday = false,
  });

  // 빈 Medication 객체를 위한 팩토리 생성자 추가
  factory Medication.empty() {
    return Medication(
      name: '',
      time: const TimeOfDay(hour: 0, minute: 0),
      baseScheduleId: -1,
      hasTakenMedicationToday: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'baseScheduleId': baseScheduleId,
      'hasTakenMedicationToday': hasTakenMedicationToday,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      baseScheduleId: json['baseScheduleId'],
      hasTakenMedicationToday: json['hasTakenMedicationToday'],
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}, baseScheduleId: $baseScheduleId, hasTakenMedicationToday: $hasTakenMedicationToday)';
  }

  Medication copyWith({
    String? name,
    TimeOfDay? time,
    int? baseScheduleId,
  }) {
    return Medication(
      name: name ?? this.name,
      time: time ?? this.time,
      baseScheduleId: baseScheduleId ?? this.baseScheduleId,
      hasTakenMedicationToday: hasTakenMedicationToday,
    );
  }
}
