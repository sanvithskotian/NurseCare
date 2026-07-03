import 'package:flutter/material.dart';
import '../../models/nursing_note.dart';
import '../../services/dummy_data.dart';

class NurseNotesScreen extends StatefulWidget {
  const NurseNotesScreen({super.key});

  @override
  State<NurseNotesScreen> createState() => _NurseNotesScreenState();
}

class _NurseNotesScreenState extends State<NurseNotesScreen> {
  final noteController = TextEditingController();

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour == 0
          ? 12
          : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";

    return "$day/$month/$year, $hour:$minute $period";
  }

  void addNote() {
    if (noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a note"),
        ),
      );
      return;
    }

    setState(() {
      DummyData.nursingNotes.add(
        NursingNote(
          id: "NN${DummyData.nursingNotes.length + 1}",
          nurseName: DummyData.nurse.name,
          patientName: DummyData.patient.name,
          note: noteController.text.trim(),
          date: _formatDateTime(DateTime.now()),
        ),
      );
    });

    noteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note added successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = DummyData.nursingNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Notes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Enter Note",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: addNote,
            child: const Text("Add Note"),
          ),
          const SizedBox(height: 20),
          const Text(
            "Existing Notes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...notes.map(
            (note) => Card(
              child: ListTile(
                leading: const Icon(Icons.note),
                title: Text(note.note),
                subtitle: Text(
                  "${note.nurseName} • ${note.date}",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}