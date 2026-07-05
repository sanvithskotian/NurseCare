import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

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
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 10),

StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('diagnoses')
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

    final diagnoses = snapshot.data!.docs;

    if (diagnoses.isEmpty) {
      return const Text(
        "No diagnoses available",
      );
    }

    return Column(
      children: diagnoses.map((doc) {
        final data =
            doc.data() as Map<String, dynamic>;

        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.medical_information,
            ),
            title: Text(
              data['diagnosis'] ?? '',
            ),
            subtitle: Text(
              "${data['doctorName'] ?? ''} • "
              "${data['date'] ?? ''}",
            ),
          ),
        );
      }).toList(),
    );
  },
),

          const SizedBox(height: 20),

          const Text(
            "Nursing Notes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      return const Text("No nursing notes available");
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