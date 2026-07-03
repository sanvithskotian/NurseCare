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
        centerTitle: true,
      ),
      body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildStatCard("Patients", totalPatients.toString(), Icons.people, Colors.blue),
            _buildStatCard("Doctors", totalDoctors.toString(), Icons.local_hospital, Colors.green),
            _buildStatCard("Nurses", totalNurses.toString(), Icons.medical_services, Colors.orange),
            _buildStatCard("Appointments", totalAppointments.toString(), Icons.calendar_month, Colors.purple),
            _buildStatCard("Prescriptions", totalPrescriptions.toString(), Icons.medication, Colors.red),
          ],
        ),
      ),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.bar_chart),
          label: const Text("View Hospital Reports"),
        ),
      ),
    ],
  ),
),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}