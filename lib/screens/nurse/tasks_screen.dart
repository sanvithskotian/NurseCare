import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final tasks = DummyData.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse Tasks"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Card(
            child: CheckboxListTile(
              title: Text(task.title),
              subtitle: Text(
                task.completed
                    ? "Completed"
                    : "Pending",
              ),
              value: task.completed,
              onChanged: (value) {
                setState(() {
                  task.completed = value ?? false;
                });
              },
            ),
          );
        },
      ),
    );
  }
}