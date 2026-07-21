import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDiagnosisScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorDiagnosisScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorDiagnosisScreen> createState() =>
      _DoctorDiagnosisScreenState();
}

class _DoctorDiagnosisScreenState
    extends State<DoctorDiagnosisScreen> {
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
        const SnackBar(
          content: Text("Please enter a diagnosis"),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doctor is not logged in"),
        ),
      );
      return;
    }

    final doctorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final doctorName =
        doctorDoc.data()?['name']?.toString() ?? 'Unknown Doctor';

    await FirebaseFirestore.instance.collection('diagnoses').add({
      'patientId': widget.patientId,
      'patientName': widget.patientName,
      'doctorId': user.uid,
      'doctorName': doctorName,
      'diagnosis': diagnosisController.text.trim(),
      'date': _formatDateTime(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    });

    diagnosisController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Diagnosis added successfully"),
      ),
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
        title: Text("${widget.patientName} - Diagnosis"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: diagnosisController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Diagnosis for ${widget.patientName}",
              border: const OutlineInputBorder(),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('diagnoses')
                .where(
                  'patientId',
                  isEqualTo: widget.patientId,
                )
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

              final diagnoses = snapshot.data?.docs ?? [];

              if (diagnoses.isEmpty) {
                return const Text(
                  "No diagnosis added for this patient",
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
                        data['diagnosis']?.toString() ?? '',
                      ),
                      subtitle: Text(
                        "${data['doctorName']?.toString() ?? ''} • "
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