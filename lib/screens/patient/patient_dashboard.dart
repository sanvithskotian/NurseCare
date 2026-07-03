import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'medical_history_screen.dart';
import 'prescriptions_screen.dart';
import 'profile_screen.dart';
import 'book_appointment_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _buildCard(
            context,
            "Appointments",
            Icons.calendar_month,
            const BookAppointmentScreen(),
          ),
          _buildCard(
            context,
            "Prescriptions",
            Icons.medication,
            const PrescriptionsScreen(),
          ),
          _buildCard(
            context,
            "Medical History",
            Icons.history,
            const MedicalHistoryScreen(),
          ),
          _buildCard(
            context,
            "Profile",
            Icons.person,
            const ProfileScreen(),
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
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
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
            Icon(icon, size: 50),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}