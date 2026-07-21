import 'package:flutter/material.dart';
import 'doctor_prescription_screen.dart';
import 'doctor_diagnosis_screen.dart';
import '../nurse/vitals_screen.dart';

class DoctorPatientDetailsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const DoctorPatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(patientName),
              subtitle: Text(
                "Patient ID: $patientId",
              ),
            ),
          ),
          const SizedBox(height: 20),
          _actionCard(
            context,
            "Add Diagnosis",
            Icons.medical_information,
            DoctorDiagnosisScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
          _actionCard(
            context,
            "Add Prescription",
            Icons.medication,
            DoctorPrescriptionScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
          _actionCard(
            context,
            "View Vitals History",
            Icons.monitor_heart,
            VitalsScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget? screen,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: screen == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => screen,
                  ),
                );
              },
      ),
    );
  }
}