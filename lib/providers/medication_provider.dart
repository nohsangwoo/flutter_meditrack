import 'package:flutter/material.dart';
import 'package:meditrack/models/medication.dart';
import 'package:meditrack/services/notification_service.dart';
import 'package:meditrack/services/storage_service.dart';

class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await StorageService().saveMedications(_medications);
    await NotificationService().scheduleMedicationNotification(medication);
    notifyListeners();
  }

  Future<void> loadMedications() async {
    _medications = await StorageService().loadMedications();
    for (var medication in _medications) {
      await NotificationService().scheduleMedicationNotification(medication);
    }
    notifyListeners();
  }

  Future<void> deleteMedication(Medication medication) async {
    _medications.remove(medication);
    await StorageService().saveMedications(_medications);
    await NotificationService().cancelNotification(medication.baseScheduleId);
    notifyListeners();
  }

  Future<void> deleteAllMedications() async {
    _medications = [];
    await StorageService().deleteAllMedications();
    await NotificationService().cancelAllNotifications();
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication,
      Medication nextMedication, int originMedicationBaseScheduleId) async {
    debugPrint(
        "updateMedication in MedicationProvider-----------------------------------");
    debugPrint("nextMedication: $nextMedication");
    debugPrint(
        "originMedicationBaseScheduleId: $originMedicationBaseScheduleId");

    await NotificationService()
        .cancelAndRescheduleMedicationNotifications(medication, nextMedication);
    await StorageService()
        .updateMedication(nextMedication, originMedicationBaseScheduleId);
    _medications = await StorageService().loadMedications();

    notifyListeners();
    debugPrint(
        "end of updateMedication in MedicationProvider-----------------------------------");
  }

  Future<void> checkAllMedications() async {
    await StorageService().checkAllMedications();
    await NotificationService().checkActiveNotifications();
  }

  Future<void> refreshMedications() async {
    _medications = await StorageService().loadMedications();
    notifyListeners();
  }
}
