import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'dart:convert';

class MedicationListItem extends StatelessWidget {
  final Medication medication;
  final Function(Medication) onDelete;

  const MedicationListItem({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(medication.name),
      subtitle: Text('복용 시간: ${medication.time.format(context)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _showDeleteConfirmation(context),
      ),
      onTap: () {
        debugPrint("specific medication in medication_list_item: $medication");

        // 리스트목록에서 클릭시 알람상세페이지로 이동하는 경우
        // 알람 탭에서 선택시 알람상세페이지로 이동하는 경우는 home_screen.dart에서 처리
        final payload = jsonEncode({
          'baseScheduleId': medication.baseScheduleId,
          'medicationName': medication.name,
          'scheduledDate': medication.time.format(context),
        });
        Navigator.pushNamed(context, '/detail_alarm', arguments: payload);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알람 삭제'),
          content: const Text('이 알람을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(medication);
              },
            ),
          ],
        );
      },
    );
  }
}
