import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patient.name),
                subtitle: Text(
                  "ID: ${patient.id} | Age: ${patient.age}",
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: const [
                  _DashboardCard(
                    title: "Patients",
                    icon: Icons.people,
                  ),
                  _DashboardCard(
                    title: "Diagnosis",
                    icon: Icons.medical_information,
                  ),
                  _DashboardCard(
                    title: "Prescription",
                    icon: Icons.medication,
                  ),
                  _DashboardCard(
                    title: "Appointments",
                    icon: Icons.calendar_month,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}