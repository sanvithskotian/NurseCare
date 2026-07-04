import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'nurse_patients_screen.dart';
import 'tasks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../role_selection/role_selection_screen.dart';

class NurseDashboard extends StatelessWidget {
  const NurseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final nurse = DummyData.nurse;
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Dashboard"),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${nurse.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Department: ${nurse.department}"),
                  Text("Assigned Patient: ${patient.name}"),
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
              _buildCard(context, "Patients", Icons.people, const NursePatientsScreen(),),
              _buildCard(context, "Tasks", Icons.task, const TasksScreen(),),
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
                  MaterialPageRoute(builder: (_) => screen),
                );
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.teal),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}