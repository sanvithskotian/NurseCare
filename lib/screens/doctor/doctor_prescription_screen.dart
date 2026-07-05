import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  const DoctorPrescriptionScreen({super.key});

  @override
  State<DoctorPrescriptionScreen> createState() =>
      _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  final medicineController = TextEditingController();
  final dosageController = TextEditingController();
  final durationController = TextEditingController();

  Future<void> addPrescription() async {
    if (medicineController.text.trim().isEmpty ||
        dosageController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('prescriptions').add({
      'patientName': 'John Doe',
      'doctorName': 'Dr. Smith',
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
      const SnackBar(content: Text("Prescription added successfully")),
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
        title: const Text("Doctor Prescriptions"),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('prescriptions')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final prescriptions = snapshot.data!.docs;

              if (prescriptions.isEmpty) {
                return const Text("No prescriptions added yet");
              }

              return Column(
                children: prescriptions.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication),
                      title: Text(data['medicine'] ?? ''),
                      subtitle: Text(
                        "${data['dosage'] ?? ''}\nDuration: ${data['duration'] ?? ''}",
                      ),
                      trailing: Text(data['doctorName'] ?? ''),
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