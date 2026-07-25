import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  Future<void> updateAppointmentStatus(
    BuildContext context,
    String documentId,
    String patientId,
    String doctorId,
    String doctorName,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(documentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (status == 'Approved') {
        await FirebaseFirestore.instance.collection('users').doc(patientId).update({
          'assignedDoctorId': doctorId,
          'assignedDoctorName': doctorName,
        });
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment $status")),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update appointment: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = FirebaseAuth.instance.currentUser;

    if (doctor == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointments"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where(
              'doctorId',
              isEqualTo: doctor.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final appointments = snapshot.data?.docs ?? [];

          appointments.sort((firstDocument, secondDocument) {
            final firstData =
                firstDocument.data() as Map<String, dynamic>;

            final secondData =
                secondDocument.data() as Map<String, dynamic>;

            final firstCreatedAt =
                firstData['createdAt'] as Timestamp?;

            final secondCreatedAt =
                secondData['createdAt'] as Timestamp?;

            if (firstCreatedAt == null || secondCreatedAt == null) {
              return 0;
            }

            return secondCreatedAt.compareTo(firstCreatedAt);
          });

          if (appointments.isEmpty) {
            return const Center(
              child: Text("No appointments assigned to you"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final document = appointments[index];

              final data =
                  document.data() as Map<String, dynamic>;

              final status =
                  data['status']?.toString() ?? 'Pending';

              final patientName =
                  data['patientName']?.toString() ?? 'Patient';

              final patientEmail =
                  data['patientEmail']?.toString() ?? '';

              final patientId = data['patientId']?.toString() ?? '';
              final doctorName = data['doctorName']?.toString() ?? '';

              final date =
                  data['date']?.toString() ?? '';

              final time =
                  data['time']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          patientEmail.isEmpty
                              ? "Date: $date\nTime: $time"
                              : "$patientEmail\nDate: $date\nTime: $time",
                        ),
                        trailing: Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(status),
                          ),
                        ),
                      ),

                      if (status.toLowerCase() == 'pending') ...[
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  updateAppointmentStatus(
                                    context,
                                    document.id,
                                    patientId,
                                    doctor.uid,
                                    doctorName,
                                    "Approved",
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Approve"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  updateAppointmentStatus(
                                    context,
                                    document.id,
                                    patientId,
                                    doctor.uid,
                                    doctorName,
                                    "Rejected",
                                  );
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}