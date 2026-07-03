import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = DummyData.nursingNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("General Checkup"),
              subtitle: Text("January 2026"),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("Fever Treatment"),
              subtitle: Text("March 2026"),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Nursing Notes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...notes.map(
            (note) => Card(
              child: ListTile(
                leading: const Icon(Icons.note),
                title: Text(note.note),
                subtitle: Text("${note.nurseName} • ${note.date}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}