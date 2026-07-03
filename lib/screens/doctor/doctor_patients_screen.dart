import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'doctor_patient_details_screen.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
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
              subtitle: Text("ID: ${patient.id} | Age: ${patient.age}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorPatientDetailsScreen(),
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