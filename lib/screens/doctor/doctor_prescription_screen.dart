import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorPrescriptionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPrescriptionScreen> createState() =>
      _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState
    extends State<DoctorPrescriptionScreen> {
  final medicineController = TextEditingController();
  final dosageController = TextEditingController();
  final durationController = TextEditingController();

  Future<void> addPrescription() async {
    if (medicineController.text.trim().isEmpty ||
        dosageController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
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

    await FirebaseFirestore.instance
        .collection('prescriptions')
        .add({
      'patientId': widget.patientId,
      'patientName': widget.patientName,
      'doctorId': user.uid,
      'doctorName': doctorName,
      'medicine': medicineController.text.trim(),
      'dosage': dosageController.text.trim(),
      'duration': durationController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    medicineController.clear();
    dosageController.clear();
    durationController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Prescription added successfully"),
      ),
    );
  }

  @override
  void dispose() {
    medicineController.dispose();
    dosageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      cursorColor: Colors.teal,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.patientName} - Prescriptions"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildInputField(
            label: "Medicine Name",
            controller: medicineController,
          ),
          const SizedBox(height: 12),
          buildInputField(
            label: "Dosage",
            controller: dosageController,
          ),
          const SizedBox(height: 12),
          buildInputField(
            label: "Duration",
            controller: durationController,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: addPrescription,
            child: const Text("Add Prescription"),
          ),
          const SizedBox(height: 20),
          const Text(
            "Existing Prescriptions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('prescriptions')
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

              final prescriptions = snapshot.data?.docs ?? [];

              if (prescriptions.isEmpty) {
                return const Text(
                  "No prescriptions added for this patient",
                );
              }

              return Column(
                children: prescriptions.map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication),
                      title: Text(
                        data['medicine']?.toString() ?? '',
                      ),
                      subtitle: Text(
                        "${data['dosage']?.toString() ?? ''}\n"
                        "Duration: ${data['duration']?.toString() ?? ''}",
                      ),
                      trailing: Text(
                        data['doctorName']?.toString() ?? '',
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