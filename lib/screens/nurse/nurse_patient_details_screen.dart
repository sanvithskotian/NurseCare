import 'package:flutter/material.dart';
import 'nurse_notes_screen.dart';
import 'vitals_screen.dart';
import 'update_vitals_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../patient/profile_screen.dart';

class NursePatientDetailsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const NursePatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Care Details"),
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

    final patient =
        snapshot.data!.data() as Map<String, dynamic>;

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
                "Patient ID: ${patient['patientId'] ?? 'Not Assigned'}",
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
                                child: Text(
                                  "• $nurse",
                                ),
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
  "View Patient Profile",
  Icons.person_outline,
  ProfileScreen(
    patientId: patientId,
  ),
),
          _actionCard(
            context,
            "Update Vitals",
            Icons.favorite,
            UpdateVitalsScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
          _actionCard(
            context,
            "Vitals History",
            Icons.monitor_heart,
            VitalsScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
          _actionCard(
            context,
            "Add Nursing Notes",
            Icons.note,
            NurseNotesScreen(
              patientId: patientId,
              patientName: patientName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
      ),
    );
  }
}