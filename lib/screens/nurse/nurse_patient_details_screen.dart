import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'nurse_notes_screen.dart';
import 'vitals_screen.dart';

class NursePatientDetailsScreen extends StatelessWidget {
  const NursePatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Care Details"),
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
              subtitle: Text(
                "ID: ${patient.id}\nAge: ${patient.age}\nBlood Group: ${patient.bloodGroup}",
              ),
            ),
          ),
          const SizedBox(height: 20),
          _actionCard(
            context,
            "Update Vitals",
            Icons.favorite,
            const VitalsScreen(),
          ),
          _actionCard(
            context,
            "Add Nursing Notes",
            Icons.note,
            const NurseNotesScreen(),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}