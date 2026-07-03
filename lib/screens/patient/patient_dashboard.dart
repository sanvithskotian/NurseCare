import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'book_appointment_screen.dart';
import 'medical_history_screen.dart';
import 'prescriptions_screen.dart';
import 'profile_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
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
                    "Welcome, ${patient.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Patient ID: ${patient.id}"),
                  Text("Blood Group: ${patient.bloodGroup}"),
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
              _buildCard(context, "Appointments", Icons.calendar_month,
                  const BookAppointmentScreen()),
              _buildCard(context, "Prescriptions", Icons.medication,
                  const PrescriptionsScreen()),
              _buildCard(context, "Medical History", Icons.history,
                  const MedicalHistoryScreen()),
              _buildCard(context, "Profile", Icons.person,
                  const ProfileScreen()),
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
    Widget screen,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.teal),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}