import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class ManagePatientsScreen extends StatelessWidget {
  const ManagePatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Patients")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(patient.name),
              subtitle: Text("ID: ${patient.id} | Age: ${patient.age}"),
            ),
          ),
        ],
      ),
    );
  }
}