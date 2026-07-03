import 'package:flutter/material.dart';
import 'reports_screen.dart';

class ManagementDashboard extends StatelessWidget {
  const ManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Management Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Welcome, Admin\nManage hospital operations from here.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _managementTile(
            context,
            "Manage Patients",
            Icons.people,
            null,
          ),
          _managementTile(
            context,
            "Manage Doctors",
            Icons.local_hospital,
            null,
          ),
          _managementTile(
            context,
            "Manage Nurses",
            Icons.medical_services,
            null,
          ),
          _managementTile(
            context,
            "Hospital Reports",
            Icons.bar_chart,
            const ReportsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _managementTile(
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