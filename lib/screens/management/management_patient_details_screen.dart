import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../patient/profile_screen.dart';

class ManagementPatientDetailsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final VoidCallback onManageMedicalTeam;

  const ManagementPatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.onManageMedicalTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(patientId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Unable to load patient details.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text("Loading..."),
                  ),
                );
              }

              if (!snapshot.data!.exists ||
                  snapshot.data!.data() == null) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Patient not found.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final patient =
                  snapshot.data!.data() as Map<String, dynamic>;

              final customPatientId =
                  patient['patientId']?.toString() ??
                      'Not Assigned';

              final doctorName =
                  patient['assignedDoctorName']?.toString();

              final nurseNames = List<String>.from(
                patient['assignedNurseNames'] ?? [],
              );

              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
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
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "Patient ID: $customPatientId",
                        ),
                      ),
                      const Divider(),
                      const Text(
                        "Assigned Medical Team",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.medical_services,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doctorName == null ||
                                      doctorName.isEmpty
                                  ? "Doctor: Not Assigned"
                                  : "Doctor: $doctorName",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: nurseNames.isEmpty
                                ? const Text(
                                    "Nurses: Not Assigned",
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Nurses:",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...nurseNames.map(
                                        (nurse) => Padding(
                                          padding:
                                              const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: Text("• $nurse"),
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
              );
            },
          ),
          const SizedBox(height: 20),
          _actionCard(
            context,
            title: "View Patient Profile",
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    patientId: patientId,
                  ),
                ),
              );
            },
          ),
          _actionCard(
            context,
            title: "Manage Doctor & Nurses",
            icon: Icons.manage_accounts_outlined,
            onTap: onManageMedicalTeam,
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}