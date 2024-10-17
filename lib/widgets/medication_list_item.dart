import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationListItem extends StatelessWidget {
  final Medication medication;

  const MedicationListItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(medication.name),
      subtitle: Text('복용 시간: ${medication.time.format(context)}'),
    );
  }
}
