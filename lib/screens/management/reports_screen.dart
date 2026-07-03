import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalPatients = 1;
    final totalDoctors = 1;
    final totalNurses = 1;
    final totalAppointments = DummyData.appointments.length;
    final totalPrescriptions = DummyData.prescriptions.length;
    final totalNursingNotes = DummyData.nursingNotes.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Reports"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportTile("Total Patients", totalPatients, Icons.people),
          _reportTile("Total Doctors", totalDoctors, Icons.local_hospital),
          _reportTile("Total Nurses", totalNurses, Icons.medical_services),
          _reportTile("Total Appointments", totalAppointments, Icons.calendar_month),
          _reportTile("Total Prescriptions", totalPrescriptions, Icons.medication),
          _reportTile("Total Nursing Notes", totalNursingNotes, Icons.note),
        ],
      ),
    );
  }

  Widget _reportTile(String title, int value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}