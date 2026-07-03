import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class ManageNursesScreen extends StatelessWidget {
  const ManageNursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nurse = DummyData.nurse;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Nurses")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.teal),
              title: Text(nurse.name),
              subtitle: Text("Department: ${nurse.department}"),
            ),
          ),
        ],
      ),
    );
  }
}