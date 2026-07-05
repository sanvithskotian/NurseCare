import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDiagnosisScreen extends StatefulWidget {
  const DoctorDiagnosisScreen({super.key});

  @override
  State<DoctorDiagnosisScreen> createState() => _DoctorDiagnosisScreenState();
}

class _DoctorDiagnosisScreenState extends State<DoctorDiagnosisScreen> {
  final diagnosisController = TextEditingController();

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

  Future<void> addDiagnosis() async {
    if (diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter diagnosis")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('diagnoses').add({
      'patientName': 'John Doe',
      'doctorName': 'Dr. Smith',
      'diagnosis': diagnosisController.text.trim(),
      'date': _formatDateTime(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    });

    diagnosisController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Diagnosis added successfully")),
    );
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: diagnosisController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Enter Diagnosis",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: addDiagnosis,
            child: const Text("Add Diagnosis"),
          ),
          const SizedBox(height: 20),
          const Text(
            "Diagnosis History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('diagnoses')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final diagnoses = snapshot.data!.docs;

              if (diagnoses.isEmpty) {
                return const Text("No diagnosis added yet");
              }

              return Column(
                children: diagnoses.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_information),
                      title: Text(data['diagnosis'] ?? ''),
                      subtitle: Text(
                        "${data['doctorName'] ?? ''} • ${data['date'] ?? ''}",
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