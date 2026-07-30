import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;

  final String title;
  final String instructions;

  final String patientId;
  final String patientName;
  final String patientCustomId;

  final String nurseId;
  final String nurseName;

  final String doctorId;
  final String doctorName;

  final String priority;
  final String status;

  final Timestamp? dueAt;
  final Timestamp? createdAt;
  final Timestamp? startedAt;
  final Timestamp? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.instructions,
    required this.patientId,
    required this.patientName,
    required this.patientCustomId,
    required this.nurseId,
    required this.nurseName,
    required this.doctorId,
    required this.doctorName,
    required this.priority,
    required this.status,
    this.dueAt,
    this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Task(
      id: document.id,
      title: data['title']?.toString() ?? '',
      instructions: data['instructions']?.toString() ?? '',
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      patientCustomId:
          data['patientCustomId']?.toString() ?? '',
      nurseId: data['nurseId']?.toString() ?? '',
      nurseName: data['nurseName']?.toString() ?? '',
      doctorId: data['doctorId']?.toString() ?? '',
      doctorName: data['doctorName']?.toString() ?? '',
      priority: data['priority']?.toString() ?? 'medium',
      status: data['status']?.toString() ?? 'pending',
      dueAt: data['dueAt'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
      startedAt: data['startedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'instructions': instructions,
      'patientId': patientId,
      'patientName': patientName,
      'patientCustomId': patientCustomId,
      'nurseId': nurseId,
      'nurseName': nurseName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'priority': priority,
      'status': status,
      'dueAt': dueAt,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
    };
  }

  bool get isPending => status == 'pending';

  bool get isInProgress => status == 'in_progress';

  bool get isCompleted => status == 'completed';
}