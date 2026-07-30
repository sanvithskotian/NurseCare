import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'nurse_task_details_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nurseId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Tasks"),
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('nurse_tasks')
      .where('nurseId', isEqualTo: nurseId)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(snapshot.error.toString()),
      );
    }

    final docs = snapshot.data?.docs ?? [];

    if (docs.isEmpty) {
      return const Center(
        child: Text(
          "No assigned tasks yet.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final pending = docs
        .where((doc) => doc['status'] == 'pending')
        .toList();

    final inProgress = docs
        .where((doc) => doc['status'] == 'in_progress')
        .toList();

    final completed = docs
        .where((doc) => doc['status'] == 'completed')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        Text(
          "Pending (${pending.length})",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),

        ...pending.map(
          (task) => Card(
            child: ListTile(
  leading: const Icon(
    Icons.assignment,
    color: Colors.orange,
  ),
  title: Text(task['title']),
  subtitle: Text(
    "${task['patientName']}\nPriority: ${task['priority']}",
  ),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NurseTaskDetailsScreen(
          taskId: task.id,
          taskData: task.data() as Map<String, dynamic>,
        ),
      ),
    );
  },
),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "In Progress (${inProgress.length})",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        ...inProgress.map(
          (task) => Card(
            child: ListTile(
  leading: const Icon(
    Icons.play_circle_fill,
    color: Colors.blue,
  ),
  title: Text(task['title']),
  subtitle: Text(task['patientName']),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NurseTaskDetailsScreen(
          taskId: task.id,
          taskData: task.data() as Map<String, dynamic>,
        ),
      ),
    );
  },
),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Completed (${completed.length})",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),

        ...completed.map(
          (task) => Card(
            child: ListTile(
  leading: const Icon(
    Icons.check_circle,
    color: Colors.green,
  ),
  title: Text(task['title']),
  subtitle: Text(task['patientName']),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NurseTaskDetailsScreen(
          taskId: task.id,
          taskData: task.data() as Map<String, dynamic>,
        ),
      ),
    );
  },
),
          ),
        ),
      ],
    );
  },
),
    );
  }
}