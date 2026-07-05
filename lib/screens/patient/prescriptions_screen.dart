import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
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

          final prescriptions = snapshot.data!.docs;

          if (prescriptions.isEmpty) {
            return const Center(
              child: Text("No prescriptions available"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final data = prescriptions[index].data()
                  as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(data['medicine'] ?? ''),
                  subtitle: Text(
                    "${data['dosage'] ?? ''}\n"
                    "Duration: ${data['duration'] ?? ''}",
                  ),
                  trailing: Text(
                    data['doctorName'] ?? '',
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