import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vitals History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vitals')
            .orderBy('createdAt', descending: true)
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

          final vitals = snapshot.data!.docs;

          if (vitals.isEmpty) {
            return const Center(
              child: Text("No vitals recorded yet"),
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
                    data['dateTime'] ?? '',
                  ),
                  subtitle: Text(
                    "Temp: ${data['temperature'] ?? ''}\n"
                    "BP: ${data['bloodPressure'] ?? ''}\n"
                    "Heart Rate: ${data['heartRate'] ?? ''}\n"
                    "Oxygen: ${data['oxygenLevel'] ?? ''}",
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