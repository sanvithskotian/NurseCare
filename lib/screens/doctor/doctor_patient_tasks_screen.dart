import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'create_nurse_task_screen.dart';

class DoctorPatientTasksScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const DoctorPatientTasksScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$patientName - Nurse Tasks"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('nurse_tasks')
            .where('patientId', isEqualTo: patientId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No nurse tasks created yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final pending = docs.where((doc) {
            return doc['status'] == 'pending';
          }).toList();

          final inProgress = docs.where((doc) {
            return doc['status'] == 'in_progress';
          }).toList();

          final completed = docs.where((doc) {
            return doc['status'] == 'completed';
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _section(
                "Pending Tasks",
                pending,
                Colors.orange,
              ),

              const SizedBox(height: 20),

              _section(
                "In Progress",
                inProgress,
                Colors.blue,
              ),

              const SizedBox(height: 20),

              _section(
                "Completed",
                completed,
                Colors.green,
              ),
            ],
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNurseTaskScreen(
                patientId: patientId,
                patientName: patientName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Task"),
      ),
    );
  }

  Widget _section(
    String title,
    List<QueryDocumentSnapshot> tasks,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          "$title (${tasks.length})",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 10),

        if (tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "No $title",
              ),
            ),
          ),

        ...tasks.map((task) {

          final data =
              task.data() as Map<String, dynamic>;

          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                ),
              ),

              title: Text(
                data['title'] ?? '',
              ),

              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 4),

                  Text(
                    "Assigned To : ${data['nurseName']}",
                  ),

                  Text(
                    "Priority : ${data['priority']}",
                  ),

                  Text(
                    "Status : ${data['status']}",
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}