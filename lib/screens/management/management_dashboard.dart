import 'package:flutter/material.dart';
import 'reports_screen.dart';
import 'manage_patients_screen.dart';
import 'manage_doctors_screen.dart';
import 'manage_nurses_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../role_selection/role_selection_screen.dart';

class ManagementDashboard extends StatelessWidget {
  const ManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Management Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
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
            const ManagePatientsScreen(),
          ),
          _managementTile(
            context,
            "Manage Doctors",
            Icons.local_hospital,
            const ManageDoctorsScreen()
          ),
          _managementTile(
            context,
            "Manage Nurses",
            Icons.medical_services,
            const ManageNursesScreen()
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