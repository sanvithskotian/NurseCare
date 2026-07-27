import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePatientsScreen extends StatelessWidget {
  const ManagePatientsScreen({super.key});

  Future<void> showDoctorAssignmentDialog(
    BuildContext context,
    String patientId,
    String patientName,
    String? currentDoctorId,
  ) async {
    String? selectedDoctorId = currentDoctorId;
    String? selectedDoctorName;

    final doctorsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    if (!context.mounted) return;

    if (doctorsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No doctors available"),
        ),
      );
      return;
    }

    if (currentDoctorId != null) {
      final currentDoctor = doctorsSnapshot.docs.where(
        (document) => document.id == currentDoctorId,
      );

      if (currentDoctor.isNotEmpty) {
        final doctorData =
            currentDoctor.first.data();

        selectedDoctorName =
            doctorData['name']?.toString();
      } else {
        selectedDoctorId = null;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Assign Doctor to $patientName"),
              content: DropdownButtonFormField<String>(
                initialValue: selectedDoctorId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Select Doctor",
                  border: OutlineInputBorder(),
                ),
                items: doctorsSnapshot.docs.map((document) {
                  final doctor = document.data();

                  final doctorName =
                      doctor['name']?.toString() ??
                          'Doctor';

                  final specialization =
                      doctor['specialization']?.toString() ??
                          'General';

                  return DropdownMenuItem<String>(
                    value: document.id,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          specialization,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return doctorsSnapshot.docs.map((document) {
                    final doctor = document.data();

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        doctor['name']?.toString() ??
                            'Doctor',
                      ),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  if (value == null) return;

                  final selectedDocument =
                      doctorsSnapshot.docs.firstWhere(
                    (document) => document.id == value,
                  );

                  setDialogState(() {
                    selectedDoctorId = value;
                    selectedDoctorName =
                        selectedDocument
                            .data()['name']
                            ?.toString() ??
                        'Doctor';
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: selectedDoctorId == null
                      ? null
                      : () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(patientId)
                                .update({
                              'assignedDoctorId':
                                  selectedDoctorId,
                              'assignedDoctorName':
                                  selectedDoctorName,
                              'doctorAssignedAt':
                                  FieldValue.serverTimestamp(),
                              'doctorAssignmentSource':
                                  'Management',
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  "$patientName assigned to $selectedDoctorName",
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Failed to assign doctor: $error",
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text("Assign"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Patients"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong."),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final patients = snapshot.data?.docs ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Text(
                "No patients found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final document = patients[index];

              final patient =
                  document.data() as Map<String, dynamic>;

              final patientName =
                  patient['name']?.toString() ??
                      'Unknown';

              final patientEmail =
                  patient['email']?.toString() ??
                      'No Email';

              final assignedDoctorId =
                  patient['assignedDoctorId']?.toString();

              final assignedDoctorName =
                  patient['assignedDoctorName']
                      ?.toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(patientName),
                  subtitle: Text(
                    assignedDoctorName == null ||
                            assignedDoctorName.isEmpty
                        ? "$patientEmail\nDoctor: Not assigned"
                        : "$patientEmail\nDoctor: $assignedDoctorName",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.medical_services_outlined,
                  ),
                  onTap: () {
                    showDoctorAssignmentDialog(
                      context,
                      document.id,
                      patientName,
                      assignedDoctorId,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}