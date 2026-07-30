import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              .toList()
            ..sort((a, b) {
              final aDue = a['dueAt'] as Timestamp;
              final bDue = b['dueAt'] as Timestamp;
              return aDue.compareTo(bDue);
            });

          final inProgress = docs
              .where((doc) => doc['status'] == 'in_progress')
              .toList()
            ..sort((a, b) {
              final aDue = a['dueAt'] as Timestamp;
              final bDue = b['dueAt'] as Timestamp;
              return aDue.compareTo(bDue);
            });

          final completed = docs
              .where((doc) => doc['status'] == 'completed')
              .toList()
            ..sort((a, b) {
              final aCompleted = a['completedAt'] as Timestamp?;
              final bCompleted = b['completedAt'] as Timestamp?;

              if (aCompleted == null || bCompleted == null) return 0;

              return bCompleted.compareTo(aCompleted);
            });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Task Overview",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: "Pending",
                      count: pending.length,
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _summaryCard(
                      title: "Active",
                      count: inProgress.length,
                      icon: Icons.play_circle_outline,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _summaryCard(
                      title: "Done",
                      count: completed.length,
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                "Pending (${pending.length})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 6),

              ...pending.map(
                (task) => _buildTaskCard(context, task),
              ),

              const SizedBox(height: 22),

              Text(
                "In Progress (${inProgress.length})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 6),

              ...inProgress.map(
                (task) => _buildTaskCard(context, task),
              ),

              const SizedBox(height: 22),

              Text(
                "Completed (${completed.length})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 6),

              ...completed.map(
                (task) => _buildTaskCard(context, task),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
    Widget _summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),
          const SizedBox(height: 7),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    QueryDocumentSnapshot task,
  ) {
    final data = task.data() as Map<String, dynamic>;

    final title =
        data['title']?.toString() ?? 'Untitled Task';

    final patientName =
        data['patientName']?.toString() ?? 'Unknown Patient';

    final doctorName =
        data['doctorName']?.toString() ?? 'Unknown Doctor';

    final priority =
        data['priority']?.toString().toLowerCase() ?? 'low';

    final status =
        data['status']?.toString().toLowerCase() ?? 'pending';

    final dueTimestamp = data['dueAt'] as Timestamp?;
    final dueDateTime = dueTimestamp?.toDate();

    final bool isCompleted = status == 'completed';

    final bool isOverdue = dueDateTime != null &&
        dueDateTime.isBefore(DateTime.now()) &&
        !isCompleted;

    Color priorityColor;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;

      case 'medium':
        priorityColor = Colors.orange;
        break;

      default:
        priorityColor = Colors.green;
    }

    switch (status) {
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'In Progress';
        statusIcon = Icons.play_circle_fill;
        break;

      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;

      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.pending_actions;
    }

    return Card(
      elevation: isOverdue ? 5 : 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue
              ? Colors.red
              : Colors.transparent,
          width: isOverdue ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NurseTaskDetailsScreen(
                taskId: task.id,
                taskData: data,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withOpacity(0.12)
                          : Colors.indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.assignment_outlined,
                      color: isOverdue
                          ? Colors.red
                          : Colors.indigo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 19,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 19,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
                            const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 19,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      dueDateTime == null
                          ? 'Due time unavailable'
                          : _formatDueDate(dueDateTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: isOverdue ? Colors.red : Colors.grey.shade700,
                        fontWeight: isOverdue
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 15,
                          color: statusColor,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 15,
                          ),

                          SizedBox(width: 5),

                          Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
    String _formatDueDate(DateTime dueDateTime) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrow = today.add(
      const Duration(days: 1),
    );

    final dueDate = DateTime(
      dueDateTime.year,
      dueDateTime.month,
      dueDateTime.day,
    );

    final time = DateFormat('h:mm a').format(dueDateTime);

    if (dueDate == today) {
      return 'Due: Today • $time';
    }

    if (dueDate == tomorrow) {
      return 'Due: Tomorrow • $time';
    }

    final date = DateFormat('dd MMM yyyy').format(dueDateTime);

    return 'Due: $date • $time';
  }
}