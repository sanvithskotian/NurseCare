import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_prescription_screen.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = DummyData.doctor;
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${doctor.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Specialization: ${doctor.specialization}"),
                  Text("Current Patient: ${patient.name}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildCard(
                context,
                "Patients",
                Icons.people,
                null,
              ),
              _buildCard(
                context,
                "Diagnosis",
                Icons.medical_information,
                null,
              ),
              _buildCard(
                context,
                "Prescription",
                Icons.medication,
                const DoctorPrescriptionScreen(),
              ),
              _buildCard(
                context,
                "Appointments",
                Icons.calendar_month,
                const DoctorAppointmentsScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget? screen,
  ) {
    return Card(
      child: InkWell(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.teal,
            ),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}