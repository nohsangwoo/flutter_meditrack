import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveMedications(List<Medication> medications) async {
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
}
