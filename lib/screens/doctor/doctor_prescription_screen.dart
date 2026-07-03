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

  void addPrescription() {
    if (medicineController.text.isEmpty ||
        dosageController.text.isEmpty ||
        durationController.text.isEmpty) {
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
          medicine: medicineController.text,
          dosage: dosageController.text,
          duration: durationController.text,
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

  @override
  Widget build(BuildContext context) {
    final prescriptions = DummyData.prescriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Prescriptions"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: medicineController,
            decoration: const InputDecoration(
              labelText: "Medicine Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dosageController,
            decoration: const InputDecoration(
              labelText: "Dosage",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: durationController,
            decoration: const InputDecoration(
              labelText: "Duration",
              border: OutlineInputBorder(),
            ),
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