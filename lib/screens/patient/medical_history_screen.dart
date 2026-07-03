import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = DummyData.nursingNotes;
    final diagnoses = DummyData.diagnoses;

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

          const SizedBox(height: 20),

          const Text(
            "Doctor Diagnoses",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...diagnoses.map(
            (diagnosis) => Card(
              child: ListTile(
                leading: const Icon(Icons.medical_information),
                title: Text(diagnosis.diagnosis),
                subtitle: Text("${diagnosis.doctorName} • ${diagnosis.date}"),
              ),
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