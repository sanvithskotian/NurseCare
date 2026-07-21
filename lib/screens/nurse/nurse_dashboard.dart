import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'nurse_patients_screen.dart';
import 'tasks_screen.dart';
import '../role_selection/role_selection_screen.dart';

class NurseDashboard extends StatelessWidget {
  const NurseDashboard({super.key});

  Future<Map<String, dynamic>?> _getNurseProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final nurseDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return nurseDocument.data();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getNurseProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load nurse profile"),
            );
          }

          final nurseData = snapshot.data;

          if (nurseData == null) {
            return const Center(
              child: Text("Nurse profile not found"),
            );
          }

          final nurseName =
              nurseData['name']?.toString() ?? 'Unknown Nurse';

          final department =
              nurseData['department']?.toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, $nurseName",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (department != null &&
                          department.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text("Department: $department"),
                      ],
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
                    const NursePatientsScreen(),
                  ),
                  _buildCard(
                    context,
                    "Tasks",
                    Icons.task,
                    const TasksScreen(),
                  ),
                ],
              ),
            ],
          );
        },
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