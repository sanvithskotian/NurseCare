import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Doctor Diagnoses",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('diagnoses')
                .where(
                  'patientId',
                  isEqualTo: user.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Could not load diagnoses",
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final diagnoses = snapshot.data?.docs ?? [];

              diagnoses.sort((first, second) {
                final firstData =
                    first.data() as Map<String, dynamic>;
                final secondData =
                    second.data() as Map<String, dynamic>;

                final firstTime =
                    firstData['createdAt'] as Timestamp?;
                final secondTime =
                    secondData['createdAt'] as Timestamp?;

                if (firstTime == null && secondTime == null) {
                  return 0;
                }

                if (firstTime == null) {
                  return 1;
                }

                if (secondTime == null) {
                  return -1;
                }

                return secondTime.compareTo(firstTime);
              });

              if (diagnoses.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.medical_information),
                    title: Text("No diagnoses available"),
                  ),
                );
              }

              return Column(
                children: diagnoses.map((document) {
                  final data =
                      document.data() as Map<String, dynamic>;

                  final diagnosis =
                      data['diagnosis']?.toString() ??
                          'Diagnosis unavailable';

                  final doctorName =
                      data['doctorName']?.toString() ??
                          'Doctor';

                  final displayDate = getDisplayDate(data);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(
                        Icons.medical_information,
                      ),
                      title: Text(diagnosis),
                      subtitle: Text(
                        "$doctorName • $displayDate",
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            "Vitals History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vitals')
                .where(
                  'patientId',
                  isEqualTo: user.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Could not load vitals",
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final vitals = snapshot.data?.docs ?? [];

              vitals.sort((first, second) {
                final firstData =
                    first.data() as Map<String, dynamic>;
                final secondData =
                    second.data() as Map<String, dynamic>;

                final firstTime =
                    firstData['createdAt'] as Timestamp?;
                final secondTime =
                    secondData['createdAt'] as Timestamp?;

                if (firstTime == null && secondTime == null) {
                  return 0;
                }

                if (firstTime == null) {
                  return 1;
                }

                if (secondTime == null) {
                  return -1;
                }

                return secondTime.compareTo(firstTime);
              });

              if (vitals.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.monitor_heart),
                    title: Text("No vitals available"),
                  ),
                );
              }

              return Column(
                children: vitals.map((document) {
                  final data =
                      document.data() as Map<String, dynamic>;

                  final temperature =
                      data['temperature']?.toString() ?? 'N/A';

                  final bloodPressure =
                      data['bloodPressure']?.toString() ??
                          'N/A';

                  final heartRate =
                      data['heartRate']?.toString() ?? 'N/A';

                  final oxygenLevel =
                      data['oxygenLevel']?.toString() ??
                          'N/A';

                  final nurseName =
                      data['nurseName']?.toString() ??
                          'Nurse';

                  final displayDate = getDisplayDate(data);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.monitor_heart),
                      title: Text(
                        "Temperature: $temperature °F",
                      ),
                      subtitle: Text(
                        "Blood Pressure: $bloodPressure\n"
                        "Heart Rate: $heartRate bpm\n"
                        "Oxygen: $oxygenLevel%\n"
                        "$nurseName • $displayDate",
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            "Nursing Notes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('nursing_notes')
                .where(
                  'patientId',
                  isEqualTo: user.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Could not load nursing notes",
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes = snapshot.data?.docs ?? [];

              notes.sort((first, second) {
                final firstData =
                    first.data() as Map<String, dynamic>;
                final secondData =
                    second.data() as Map<String, dynamic>;

                final firstTime =
                    firstData['createdAt'] as Timestamp?;
                final secondTime =
                    secondData['createdAt'] as Timestamp?;

                if (firstTime == null && secondTime == null) {
                  return 0;
                }

                if (firstTime == null) {
                  return 1;
                }

                if (secondTime == null) {
                  return -1;
                }

                return secondTime.compareTo(firstTime);
              });

              if (notes.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.note),
                    title: Text("No nursing notes available"),
                  ),
                );
              }

              return Column(
                children: notes.map((document) {
                  final data =
                      document.data() as Map<String, dynamic>;

                  final note =
                      data['note']?.toString() ??
                          'Note unavailable';

                  final nurseName =
                      data['nurseName']?.toString() ??
                          'Nurse';

                  final displayDate = getDisplayDate(data);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(note),
                      subtitle: Text(
                        "$nurseName • $displayDate",
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String getDisplayDate(Map<String, dynamic> data) {
    final storedDate = data['date'];

    if (storedDate != null &&
        storedDate.toString().trim().isNotEmpty) {
      return storedDate.toString();
    }

    final createdAt = data['createdAt'];

    if (createdAt is Timestamp) {
      final dateTime = createdAt.toDate();

      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;

      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : dateTime.hour == 0
              ? 12
              : dateTime.hour;

      final minute =
          dateTime.minute.toString().padLeft(2, '0');

      final period =
          dateTime.hour >= 12 ? 'PM' : 'AM';

      return "$day/$month/$year, $hour:$minute $period";
    }

    return "Date unavailable";
  }
}