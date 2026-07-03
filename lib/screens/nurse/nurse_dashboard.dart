import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'vitals_screen.dart';
import 'nurse_notes_screen.dart';

class NurseDashboard extends StatelessWidget {
  const NurseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patient.name),
                subtitle: Text(
                  "ID: ${patient.id} | Blood Group: ${patient.bloodGroup}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildCard(
                    context,
                    "Patients",
                    Icons.people,
                    null,
                  ),
                  _buildCard(
                    context,
                    "Vitals",
                    Icons.favorite,
                    const VitalsScreen(),
                  ),
                  _buildCard(
                    context,
                    "Notes",
                    Icons.note,
                    const NurseNotesScreen(),
                  ),
                  _buildCard(
                    context,
                    "Tasks",
                    Icons.task,
                    null,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Text(title),
          ],
        ),
      ),
    );
  }
}