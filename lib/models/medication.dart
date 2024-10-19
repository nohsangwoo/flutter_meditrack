import 'package:flutter/material.dart';

class Medication {
  final String name;
  final TimeOfDay time;
  final int baseScheduleId;
  Medication({
    required this.name,
    required this.time,
    required this.baseScheduleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'baseScheduleId': baseScheduleId,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      baseScheduleId: json['baseScheduleId'],
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}, baseScheduleId: $baseScheduleId)';
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
    );
  }
}
