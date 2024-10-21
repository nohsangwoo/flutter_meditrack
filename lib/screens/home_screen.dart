import 'package:flutter/material.dart';
import 'package:meditrack/providers/medication_provider.dart';
import 'package:meditrack/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../widgets/medication_list_item.dart';
import 'add_medication_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    listenToNotifications();
    super.initState();
  }

  // to listen to any notification clicked or not
  listenToNotifications() {
    print("Listening to notification");
    NotificationService.onClickNotification.stream.listen((event) {
      print("inside listen in home.dart");
      print(event);

      // 알람 탭에서 선택시 알람상세페이지로 이동하는 경우
      // 리스트목록에서 클릭시 알람상세페이지로 이동하는 경우는  medication_list_item.dart에서 처리
      Navigator.pushNamed(context, '/detail_alarm', arguments: event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 약 목록', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 28),
            onPressed: () =>
                _showDeleteAllConfirmation(context, medicationProvider),
            tooltip: '모든 알람 삭제',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: medicationProvider.medications.isEmpty
                ? const Center(
                    child:
                        Text('약 목록이 비어있습니다.', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: medicationProvider.medications.length,
                    itemBuilder: (context, index) {
                      final sortedMedications =
                          List.from(medicationProvider.medications)
                            ..sort((a, b) {
                              final aMinutes = a.time.hour * 60 + a.time.minute;
                              final bMinutes = b.time.hour * 60 + b.time.minute;
                              return aMinutes.compareTo(bMinutes);
                            });
                      return MedicationListItem(
                        medication: sortedMedications[index],
                        onDelete: (medication) {
                          medicationProvider.deleteMedication(medication);
                        },
                      );
                    },
                  ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.stop_circle_outlined),
          //     onPressed: () async {
          //       medicationProvider.checkAllMedications();
          //     },
          //     label: const Text("check all Notifications"),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.cancel),
          //     onPressed: () async {
          //       medicationProvider.deleteAllMedications();
          //     },
          //     label: const Text("모든 알람삭제"),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.add_alert),
          //     onPressed: () async {
          //       await NotificationService()
          //           .hardcodingScheduleMedicationNotificationForTest();
          //     },
          //     label: const Text("hardcoding Notifications"),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.add_alert),
          //     onPressed: () async {
          //       await NotificationService().scheduleAllDayNotifications(2);
          //     },
          //     label: const Text("Schedule all day Notifications"),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.add_alert),
          //     onPressed: () async {
          //       await NotificationService().showScheduleNotification(
          //         title: "test",
          //         body: "test",
          //         payload: "test",
          //       );
          //     },
          //     label: const Text("Schedule Notification"),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMedicationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('복용 약 추가', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showDeleteAllConfirmation(
      BuildContext context, MedicationProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('모든 알람 삭제', style: TextStyle(fontSize: 20)),
          content:
              const Text('모든 알람을 삭제하시겠습니까?', style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: const Text('취소', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('확인', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
                provider.deleteAllMedications();
              },
            ),
          ],
        );
      },
    );
  }
}
