import 'package:flutter/material.dart';

class Medication {
  final String name;
  final TimeOfDay time;
  final int baseScheduleId;
  final bool? hasTakenMedicationToday;
  DateTime? hasTakenMedicationTodayDate;

  Medication({
    required this.name,
    required this.time,
    required this.baseScheduleId,
    this.hasTakenMedicationToday = false,
    this.hasTakenMedicationTodayDate,
  });

  // 빈 Medication 객체를 위한 팩토리 생성자 추가
  factory Medication.empty() {
    return Medication(
      name: '',
      time: const TimeOfDay(hour: 0, minute: 0),
      baseScheduleId: -1,
      hasTakenMedicationToday: false,
      hasTakenMedicationTodayDate: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'baseScheduleId': baseScheduleId,
      'hasTakenMedicationToday': hasTakenMedicationToday,
      'hasTakenMedicationTodayDate':
          hasTakenMedicationTodayDate?.toIso8601String(),
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      baseScheduleId: json['baseScheduleId'],
      hasTakenMedicationToday: json['hasTakenMedicationToday'],
      hasTakenMedicationTodayDate: json['hasTakenMedicationTodayDate'] != null
          ? DateTime.parse(json['hasTakenMedicationTodayDate'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}, baseScheduleId: $baseScheduleId, hasTakenMedicationToday: $hasTakenMedicationToday, hasTakenMedicationTodayDate: $hasTakenMedicationTodayDate)';
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
      hasTakenMedicationTodayDate: hasTakenMedicationTodayDate,
    );
  }

  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  void markAsTakenToday() {
    hasTakenMedicationTodayDate = dateOnly(DateTime.now());
  }
}
