import 'package:flutter/material.dart';
import '../../models/prescription.dart';
import '../../services/dummy_data.dart';

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

  @override
  void dispose() {
    medicineController.dispose();
    dosageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void addPrescription() {
    if (medicineController.text.trim().isEmpty ||
        dosageController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      DummyData.prescriptions.add(
        Prescription(
          id: "PR${DummyData.prescriptions.length + 1}",
          doctorName: DummyData.doctor.name,
          medicine: medicineController.text.trim(),
          dosage: dosageController.text.trim(),
          duration: durationController.text.trim(),
        ),
      );
    });

    medicineController.clear();
    dosageController.clear();
    durationController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prescription added successfully")),
    );
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      cursorColor: Colors.blue,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptions = DummyData.prescriptions;

    return Scaffold(
      backgroundColor: Colors.white,
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
          ...prescriptions.map(
            (prescription) => Card(
              child: ListTile(
                leading: const Icon(Icons.medication),
                title: Text(prescription.medicine),
                subtitle: Text(
                  "${prescription.dosage}\nDuration: ${prescription.duration}",
                ),
                trailing: Text(prescription.doctorName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}