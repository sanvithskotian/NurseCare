import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VitalsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const VitalsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$patientName - Vitals"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vitals')
            .where(
              'patientId',
              isEqualTo: patientId,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final vitals = snapshot.data?.docs ?? [];

          vitals.sort((first, second) {
            final firstData =
                first.data() as Map<String, dynamic>;
            final secondData =
                second.data() as Map<String, dynamic>;

            final firstTime =
                firstData['createdAt'] as Timestamp?;
            final secondTime =
                secondData['createdAt'] as Timestamp?;

            if (firstTime == null || secondTime == null) {
              return 0;
            }

            return secondTime.compareTo(firstTime);
          });

          if (vitals.isEmpty) {
            return Center(
              child: Text(
                "No vitals recorded for $patientName",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vitals.length,
            itemBuilder: (context, index) {
              final data =
                  vitals[index].data()
                      as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.monitor_heart,
                    color: Colors.teal,
                  ),
                  title: Text(
                    data['dateTime']?.toString() ?? '',
                  ),
                  subtitle: Text(
                    "Temp: ${data['temperature']?.toString() ?? ''}\n"
                    "BP: ${data['bloodPressure']?.toString() ?? ''}\n"
                    "Heart Rate: ${data['heartRate']?.toString() ?? ''}\n"
                    "Oxygen: ${data['oxygenLevel']?.toString() ?? ''}\n"
                    "Updated by: ${data['nurseName']?.toString() ?? 'Unknown Nurse'}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}