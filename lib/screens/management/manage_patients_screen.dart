import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() =>
      _ManagePatientsScreenState();
}

class _ManagePatientsScreenState
    extends State<ManagePatientsScreen> {
      final TextEditingController _searchController =
    TextEditingController();

String _searchQuery = '';

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

  Future<void> _showAssignmentDialog(
    BuildContext context,
    String patientId,
    String patientName,
    Map<String, dynamic> patient,
  ) async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .get(),
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'nurse')
            .get(),
      ]);

      if (!context.mounted) return;

      final doctorsSnapshot = results[0];
      final nursesSnapshot = results[1];

      String? selectedDoctorId =
          patient['assignedDoctorId']?.toString();

      String? selectedDoctorName =
          patient['assignedDoctorName']?.toString();

      final selectedNurseIds = <String>{
        ...List<String>.from(
          patient['assignedNurseIds'] ?? [],
        ),
      };

      final selectedNurseNames = <String>{
        ...List<String>.from(
          patient['assignedNurseNames'] ?? [],
        ),
      };

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          bool isSaving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> saveAssignments() async {
                setDialogState(() {
                  isSaving = true;
                });

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(patientId)
                      .update({
                    'assignedDoctorId': selectedDoctorId,
                    'assignedDoctorName': selectedDoctorName,
                    'assignedNurseIds':
                        selectedNurseIds.toList(),
                    'assignedNurseNames':
                        selectedNurseNames.toList(),
                    'assignmentUpdatedAt':
                        FieldValue.serverTimestamp(),
                    'assignmentSource': 'Management',
                  });

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Assignments updated for $patientName",
                      ),
                    ),
                  );
                } catch (error) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    isSaving = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Failed to update assignments: $error",
                      ),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: Text(
                  "Manage $patientName",
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Assigned Doctor",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        DropdownButtonFormField<String?>(
                          initialValue: selectedDoctorId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Select Doctor",
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("No doctor assigned"),
                            ),
                            ...doctorsSnapshot.docs.map(
                              (document) {
                                final doctor = document.data();

                                final doctorName =
                                    doctor['name']?.toString() ??
                                        'Unknown Doctor';

                                final specialization =
                                    doctor['specialization']
                                            ?.toString() ??
                                        'General';

                                return DropdownMenuItem<String?>(
                                  value: document.id,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctorName,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        specialization,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                          selectedItemBuilder: (context) {
                            return [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "No doctor assigned",
                                ),
                              ),
                              ...doctorsSnapshot.docs.map(
                                (document) {
                                  final doctor = document.data();

                                  return Align(
                                    alignment:
                                        Alignment.centerLeft,
                                    child: Text(
                                      doctor['name']
                                              ?.toString() ??
                                          'Unknown Doctor',
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ];
                          },
                          onChanged: isSaving
                              ? null
                              : (doctorId) {
                                  setDialogState(() {
                                    selectedDoctorId =
                                        doctorId;

                                    if (doctorId == null) {
                                      selectedDoctorName =
                                          null;
                                      return;
                                    }

                                    final selectedDoctor =
                                        doctorsSnapshot.docs
                                            .firstWhere(
                                      (document) =>
                                          document.id ==
                                          doctorId,
                                    );

                                    selectedDoctorName =
                                        selectedDoctor
                                                .data()['name']
                                                ?.toString() ??
                                            'Unknown Doctor';
                                  });
                                },
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Assigned Nurses",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          "Select one or more nurses.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (nursesSnapshot.docs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              "No nurses available.",
                            ),
                          )
                        else
                          ...nursesSnapshot.docs.map(
                            (document) {
                              final nurse = document.data();

                              final nurseName =
                                  nurse['name']?.toString() ??
                                      'Unknown Nurse';

                              final department =
                                  nurse['department']
                                          ?.toString() ??
                                      '';

                              final isSelected =
                                  selectedNurseIds.contains(
                                document.id,
                              );

                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: isSelected,
                                controlAffinity:
                                    ListTileControlAffinity
                                        .leading,
                                title: Text(nurseName),
                                subtitle: department.isEmpty
                                    ? null
                                    : Text(department),
                                onChanged: isSaving
                                    ? null
                                    : (selected) {
                                        setDialogState(() {
                                          if (selected == true) {
                                            selectedNurseIds.add(
                                              document.id,
                                            );

                                            selectedNurseNames.add(
                                              nurseName,
                                            );
                                          } else {
                                            selectedNurseIds.remove(
                                              document.id,
                                            );

                                            selectedNurseNames
                                                .remove(
                                              nurseName,
                                            );
                                          }
                                        });
                                      },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    child: const Text("Cancel"),
                  ),
                  FilledButton(
                    onPressed:
                        isSaving ? null : saveAssignments,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load staff: $error",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Patients"),
      ),
      body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by name or email...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    ),

    Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong.\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allPatients = snapshot.data?.docs ?? [];

final patients = allPatients.where((document) {
  final patient =
      document.data() as Map<String, dynamic>;

  final name =
      patient['name']?.toString().toLowerCase() ?? '';

  final email =
      patient['email']?.toString().toLowerCase() ?? '';

  final query = _searchQuery.trim().toLowerCase();

  return name.contains(query) ||
      email.contains(query);
}).toList();

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
              final patientDocument = patients[index];

              final patient = patientDocument.data()
                  as Map<String, dynamic>;

              final patientName =
                  patient['name']?.toString() ??
                      'Unknown Patient';

              final patientEmail =
                  patient['email']?.toString() ??
                      'No email available';

              final assignedDoctorName =
                  patient['assignedDoctorName']
                      ?.toString();

              final assignedNurseNames =
                  List<String>.from(
                patient['assignedNurseNames'] ?? [],
              );

              final doctorText =
                  assignedDoctorName == null ||
                          assignedDoctorName.isEmpty
                      ? "Not assigned"
                      : assignedDoctorName;

              final nurseText =
                  assignedNurseNames.isEmpty
                      ? "Not assigned"
                      : assignedNurseNames.join(', ');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "$patientEmail\n"
                      "Doctor: $doctorText\n"
                      "Nurses: $nurseText",
                    ),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.manage_accounts_outlined,
                  ),
                  onTap: () {
                    _showAssignmentDialog(
                      context,
                      patientDocument.id,
                      patientName,
                      patient,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    ),
  ],
      )
    );
  }
}