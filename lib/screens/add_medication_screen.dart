import 'package:flutter/material.dart';
import 'package:meditrack/main.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  AddMedicationScreenState createState() => AddMedicationScreenState();
}

class AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 추가'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '약 이름'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '약 이름을 입력해주세요';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null && picked != _time) {
                  setState(() {
                    _time = picked;
                  });
                }
              },
              child: Text('복용 시간 선택: ${_time.format(context)}'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final medication = Medication(
                    name: _name,
                    time: _time,
                  );
                  final navigator = Navigator.of(context);
                  final medicationProvider =
                      Provider.of<MedicationProvider>(context, listen: false);
                  medicationProvider.addMedication(medication);
                  await NotificationService()
                      .scheduleMedicationNotification(medication);
                  if (mounted) {
                    navigator.pop();
                  }
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
