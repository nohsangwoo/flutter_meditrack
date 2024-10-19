import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveMedications(List<Medication> medications) async {
    print("------------------------");
    print("saveMedications in storage service");
    print("medications: $medications");
    print("------------------------");
    if (_prefs == null) await initialize();
    final String encodedData = json.encode(
      medications.map((medication) => medication.toJson()).toList(),
    );
    await _prefs!.setString('medications', encodedData);
  }

  Future<List<Medication>> loadMedications() async {
    if (_prefs == null) await initialize();
    final String? encodedData = _prefs!.getString('medications');
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Medication.fromJson(item)).toList();
  }

  // delete all medications
  Future<void> deleteAllMedications() async {
    if (_prefs == null) await initialize();
    await _prefs!.clear();
  }

  // check all medications
  Future<List<Medication>> checkAllMedications() async {
    if (_prefs == null) await initialize();
    final String? encodedData = _prefs!.getString('medications');
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    final List<Medication> medications =
        decodedData.map((item) => Medication.fromJson(item)).toList();
    print("------------------------");
    print("checkAllMedications in storage service");
    print(medications);
    print("------------------------");
    return medications;
  }

  // update medication
  Future<void> updateMedication(
      Medication nextMedication, int originMedicationBaseScheduleId) async {
    if (_prefs == null) await initialize();
    final List<Medication> originMedication = await loadMedications();
    print("------------------------");
    print("updateMedication in storage service");
    print("nextMedication: $nextMedication");
    print("originMedication: $originMedication");
    print("originMedicationBaseScheduleId: $originMedicationBaseScheduleId");

    // find originMedication index
    final index = originMedication.indexWhere((medication) =>
        medication.baseScheduleId == originMedicationBaseScheduleId);

    print("index: $index");

    if (index == -1) return;
    originMedication[index] = nextMedication;
    print("changed originMedication[index]: $originMedication[index]");
    print("------------------------");
    // update medications

    await saveMedications(originMedication);
  }
}
