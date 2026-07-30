import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NurseTaskDetailsScreen extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const NurseTaskDetailsScreen({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  Future<void> _startTask(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('nurse_tasks')
          .doc(taskId)
          .update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task started successfully.'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _completeTask(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('nurse_tasks')
          .doc(taskId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task completed successfully.'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  String _formatDueDate(BuildContext context) {
    final dueAt = taskData['dueAt'];

    if (dueAt is! Timestamp) {
      return 'Not available';
    }

    final date = dueAt.toDate();

    final localizations = MaterialLocalizations.of(context);

    final formattedDate = localizations.formatMediumDate(date);

    final formattedTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
    );

    return '$formattedDate • $formattedTime';
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = taskData['title']?.toString() ?? 'Task';
    final instructions =
        taskData['instructions']?.toString() ?? 'No instructions provided.';
    final patientName =
        taskData['patientName']?.toString() ?? 'Unknown Patient';
    final doctorName =
        taskData['doctorName']?.toString() ?? 'Unknown Doctor';
    final priority =
        taskData['priority']?.toString() ?? 'medium';
    final status =
        taskData['status']?.toString() ?? 'pending';

    final priorityColor = _priorityColor(priority);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: priorityColor,
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _statusText(status),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _detailCard(
              icon: Icons.person,
              label: 'Patient',
              value: patientName,
            ),

            _detailCard(
              icon: Icons.medical_services,
              label: 'Assigned By',
              value: doctorName,
            ),

            _detailCard(
              icon: Icons.flag,
              label: 'Priority',
              value: priority.toUpperCase(),
              valueColor: priorityColor,
            ),

            _detailCard(
              icon: Icons.schedule,
              label: 'Due',
              value: _formatDueDate(context),
            ),

            const SizedBox(height: 12),

            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                instructions,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _startTask(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Task',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

            if (status == 'in_progress')
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _completeTask(context),
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Complete Task',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

            if (status == 'completed')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Task Completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ),
    );
  }
}