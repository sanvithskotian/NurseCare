import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'reports_screen.dart';

class ManagementDashboard extends StatelessWidget {
  const ManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final totalPatients = 1;
    final totalDoctors = 1;
    final totalNurses = 1;
    final totalAppointments = DummyData.appointments.length;
    final totalPrescriptions = DummyData.prescriptions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Management Dashboard"),
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
                  const Text(
                    "Welcome, Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Patients: $totalPatients"),
                  Text("Doctors: $totalDoctors"),
                  Text("Nurses: $totalNurses"),
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
              _buildStatCard("Patients", totalPatients.toString(), Icons.people),
              _buildStatCard("Doctors", totalDoctors.toString(), Icons.local_hospital),
              _buildStatCard("Nurses", totalNurses.toString(), Icons.medical_services),
              _buildStatCard("Appointments", totalAppointments.toString(), Icons.calendar_month),
              _buildStatCard("Prescriptions", totalPrescriptions.toString(), Icons.medication),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart),
            label: const Text("View Hospital Reports"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: Colors.teal),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}