import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nurse_patient_details_screen.dart';

class NursePatientsScreen extends StatelessWidget {
  const NursePatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Patients"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
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

          final patients = snapshot.data?.docs ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Text("No patients found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient =
                  patients[index].data()
                      as Map<String, dynamic>;

              final patientId = patients[index].id;
              final patientName =
                  patient['name']?.toString() ??
                      'Unknown Patient';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(patientName),
                  subtitle: Text(
                    patient['email']?.toString() ?? '',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NursePatientDetailsScreen(
                          patientId: patientId,
                          patientName: patientName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}