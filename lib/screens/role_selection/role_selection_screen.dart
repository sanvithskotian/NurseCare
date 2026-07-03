import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediConnect"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
               "MediConnect",
               style: TextStyle(
                 fontSize: 32,
                 fontWeight: FontWeight.bold,
                 color: Colors.teal,
                 ),
            ),

            SizedBox(height: 8),

            Text(
              "Hospital Management System",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildRoleCard(
                    context,
                    "Patient",
                    Icons.person,
                    Colors.blue,
                  ),
                  _buildRoleCard(
                    context,
                    "Nurse",
                    Icons.medical_services,
                    Colors.green,
                  ),
                  _buildRoleCard(
                    context,
                    "Doctor",
                    Icons.local_hospital,
                    Colors.red,
                  ),
                  _buildRoleCard(
                    context,
                    "Management",
                    Icons.admin_panel_settings,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
           context,
           MaterialPageRoute(
            builder: (_) => LoginScreen(role: title),
           ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade100,
              child: Icon(
                icon,
                size: 35,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}