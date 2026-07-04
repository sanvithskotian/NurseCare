import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'doctor_prescription_screen.dart';
import 'doctor_diagnosis_screen.dart';
import '../nurse/vitals_screen.dart';

class DoctorPatientDetailsScreen extends StatelessWidget {
  const DoctorPatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

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
              title: Text(patient.name),
              subtitle: Text(
                "ID: ${patient.id}\nAge: ${patient.age}\nBlood Group: ${patient.bloodGroup}",
              ),
            ),
          ),
          const SizedBox(height: 20),
          _actionCard(
            context,
            "Add Diagnosis",
            Icons.medical_information,
            const DoctorDiagnosisScreen(),
          ),
          _actionCard(
            context,
            "Add Prescription",
            Icons.medication,
            const DoctorPrescriptionScreen(),
          ),
          _actionCard(
            context,
            "View Vitals History",
            Icons.monitor_heart,
            const VitalsScreen(),
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
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: screen == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => screen),
                );
              },
      ),
    );
  }
}