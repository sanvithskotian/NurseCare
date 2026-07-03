import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class ManageDoctorsScreen extends StatelessWidget {
  const ManageDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = DummyData.doctor;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Doctors")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.teal),
              title: Text(doctor.name),
              subtitle: Text("Specialization: ${doctor.specialization}"),
            ),
          ),
        ],
      ),
    );
  }
}