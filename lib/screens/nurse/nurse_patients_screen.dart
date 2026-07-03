import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'nurse_patient_details_screen.dart';

class NursePatientsScreen extends StatelessWidget {
  const NursePatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Patients"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(patient.name),
              subtitle: Text("ID: ${patient.id} | Blood Group: ${patient.bloodGroup}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NursePatientDetailsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}