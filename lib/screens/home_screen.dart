import 'package:flutter/material.dart';
import 'package:meditrack/main.dart';
import 'package:meditrack/services/storage_service.dart';
import 'package:provider/provider.dart';
import '../widgets/medication_list_item.dart';
import 'add_medication_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 약 목록'),
      ),
      body: Column(
        children: [
          Expanded(
            child: medicationProvider.medications.isEmpty
                ? const Center(child: Text('약 목록이 비어있습니다.'))
                : ListView.builder(
                    itemCount: medicationProvider.medications.length,
                    itemBuilder: (context, index) {
                      return MedicationListItem(
                        medication: medicationProvider.medications[index],
                        onDelete: (medication) {
                          medicationProvider.deleteMedication(medication);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () async {
                final medications =
                    await StorageService().checkAllMedications();
                print(medications);
                print("check all medications buttons in home screen");
              },
              label: const Text("check all Notifications"),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMedicationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
