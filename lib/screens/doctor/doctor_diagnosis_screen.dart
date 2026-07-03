import 'package:flutter/material.dart';
import '../../models/diagnosis.dart';
import '../../services/dummy_data.dart';

class DoctorDiagnosisScreen extends StatefulWidget {
  const DoctorDiagnosisScreen({super.key});

  @override
  State<DoctorDiagnosisScreen> createState() => _DoctorDiagnosisScreenState();
}

class _DoctorDiagnosisScreenState extends State<DoctorDiagnosisScreen> {
  final diagnosisController = TextEditingController();

  void addDiagnosis() {
    if (diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter diagnosis")),
      );
      return;
    }

    setState(() {
      DummyData.diagnoses.add(
        Diagnosis(
          id: "DG${DummyData.diagnoses.length + 1}",
          doctorName: DummyData.doctor.name,
          patientName: DummyData.patient.name,
          diagnosis: diagnosisController.text.trim(),
          date: "Today",
        ),
      );
    });

    diagnosisController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Diagnosis added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnoses = DummyData.diagnoses;

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
          ...diagnoses.map(
            (diagnosis) => Card(
              child: ListTile(
                leading: const Icon(Icons.medical_information),
                title: Text(diagnosis.diagnosis),
                subtitle: Text("${diagnosis.doctorName} • ${diagnosis.date}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}