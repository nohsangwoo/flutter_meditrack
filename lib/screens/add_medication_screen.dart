import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  AddMedicationScreenState createState() => AddMedicationScreenState();
}

class AddMedicationScreenState extends State<AddMedicationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  TimeOfDay _time = TimeOfDay.now();
  final random = Random();
  final uuid = const Uuid();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showIOSTimePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: DateTime(2023, 1, 1, _time.hour, _time.minute),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newTime) {
              setState(() {
                _time = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 추가'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(_animation),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '약 이름',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.medication),
                  ),
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
              ),
              const SizedBox(height: 24.0),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(_animation),
                child: ElevatedButton.icon(
                  onPressed: _showIOSTimePicker,
                  icon: const Icon(Icons.access_time),
                  label: Text('복용 시간 선택: ${_time.format(context)}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ScaleTransition(
                scale: _animation,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      HapticFeedback.mediumImpact();
                      _formKey.currentState!.save();
                      final baseScheduleId = uuid.v4().hashCode & 0x7FFFFFFF;

                      final medication = Medication(
                        name: _name,
                        time: _time,
                        baseScheduleId: baseScheduleId,
                      );

                      final navigator = Navigator.of(context);
                      final medicationProvider =
                          Provider.of<MedicationProvider>(context,
                              listen: false);
                      await medicationProvider.addMedication(medication);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_name 약을 ${_time.format(context)}에 복용하시도록 설정해 드렸어요. 건강하세요!',
                              style: const TextStyle(fontSize: 16),
                            ),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        navigator.pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('설정 완료', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
