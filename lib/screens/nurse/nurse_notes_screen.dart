import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NurseNotesScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const NurseNotesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<NurseNotesScreen> createState() =>
      _NurseNotesScreenState();
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

    final minute =
        dateTime.minute.toString().padLeft(2, '0');
    final period =
        dateTime.hour >= 12 ? "PM" : "AM";

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

    if (!nurseDocument.exists) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nurse profile not found"),
        ),
      );
      return;
    }

    final nurseName =
        nurseDocument.data()?['name']?.toString() ??
            'Unknown Nurse';

    await FirebaseFirestore.instance
        .collection('nursing_notes')
        .add({
      'patientId': widget.patientId,
      'patientName': widget.patientName,
      'nurseId': user.uid,
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
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.patientName} - Nurse Notes"),
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
                .where(
                  'patientId',
                  isEqualTo: widget.patientId,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Something went wrong",
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes = snapshot.data?.docs ?? [];

              notes.sort((first, second) {
                final firstData =
                    first.data() as Map<String, dynamic>;
                final secondData =
                    second.data() as Map<String, dynamic>;

                final firstTime =
                    firstData['createdAt'] as Timestamp?;
                final secondTime =
                    secondData['createdAt'] as Timestamp?;

                if (firstTime == null &&
                    secondTime == null) {
                  return 0;
                }

                if (firstTime == null) {
                  return 1;
                }

                if (secondTime == null) {
                  return -1;
                }

                return secondTime.compareTo(firstTime);
              });

              if (notes.isEmpty) {
                return Text(
                  "No notes added for ${widget.patientName}",
                );
              }

              return Column(
                children: notes.map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(
                        data['note']?.toString() ?? '',
                      ),
                      subtitle: Text(
                        "${data['nurseName']?.toString() ?? 'Unknown Nurse'} • "
                        "${data['date']?.toString() ?? ''}",
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