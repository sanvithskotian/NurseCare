import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where(
              'patientId',
              isEqualTo: user.uid,
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

          final prescriptions = snapshot.data?.docs ?? [];

          prescriptions.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final timeA = dataA['createdAt'] as Timestamp?;
            final timeB = dataB['createdAt'] as Timestamp?;

            if (timeA == null || timeB == null) {
              return 0;
            }

            return timeB.compareTo(timeA);
          });

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
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.medication),
                  ),
                  title: Text(
                    data['medicine'] ?? 'Medicine',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Dosage: ${data['dosage'] ?? 'N/A'}\n"
                    "Duration: ${data['duration'] ?? 'N/A'}",
                  ),
                  trailing: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Doctor",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        data['doctorName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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