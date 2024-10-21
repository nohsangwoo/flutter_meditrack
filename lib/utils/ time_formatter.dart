import 'package:flutter/material.dart';

String formatTime(TimeOfDay time) {
  final hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour < 12 ? '오전' : '오후';
  final formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString();

  return '$period $formattedHour:$minute';
}
