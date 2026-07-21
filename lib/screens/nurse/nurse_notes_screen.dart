import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> addNote() async {
  if (noteController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter a note"),
      ),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nurse is not logged in"),
      ),
    );
    return;
  }

  final nurseDocument = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final nurseName =
      nurseDocument.data()?['name']?.toString() ?? 'Unknown Nurse';

  await FirebaseFirestore.instance
      .collection('nursing_notes')
      .add({
    'patientName': 'John Doe',
    'nurseName': nurseName,
    'note': noteController.text.trim(),
    'date': _formatDateTime(DateTime.now()),
    'createdAt': FieldValue.serverTimestamp(),
  });

  noteController.clear();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Note added successfully"),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
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
         StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('nursing_notes')
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Text("Something went wrong");
    }

    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final notes = snapshot.data!.docs;

    if (notes.isEmpty) {
      return const Text("No notes added yet");
    }

    return Column(
      children: notes.map((doc) {
        final data =
            doc.data() as Map<String, dynamic>;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.note),
            title: Text(data['note'] ?? ''),
            subtitle: Text(
              "${data['nurseName'] ?? ''} • "
              "${data['date'] ?? ''}",
            ),
          ),
        );
      }).toList(),
    );
  },
),
        ],
      ),
    );
  }
}