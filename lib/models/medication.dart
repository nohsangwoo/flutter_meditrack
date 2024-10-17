import 'package:flutter/material.dart';

class Medication {
  final String name;
  final TimeOfDay time;

  Medication({required this.name, required this.time});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, time: ${time.hour}:${time.minute.toString().padLeft(2, '0')})';
  }
}
