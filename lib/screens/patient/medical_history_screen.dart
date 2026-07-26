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
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('diagnoses')
      .where(
        'patientId',
        isEqualTo: user.uid,
      )
      .snapshots(),
  builder: (context, diagnosisSnapshot) {
    if (diagnosisSnapshot.hasError) {
      return const Center(
        child: Text("Could not load medical history"),
      );
    }

    if (diagnosisSnapshot.connectionState ==
        ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('nursing_notes')
          .where(
            'patientId',
            isEqualTo: user.uid,
          )
          .snapshots(),
      builder: (context, notesSnapshot) {
        if (notesSnapshot.hasError) {
          return const Center(
            child: Text("Could not load medical history"),
          );
        }

        if (notesSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final diagnoses =
            diagnosisSnapshot.data?.docs ?? [];

        final notes =
            notesSnapshot.data?.docs ?? [];

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

        if (diagnoses.isEmpty && notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Medical History Yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your diagnoses and nursing notes will appear here after your hospital visit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
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

            if (diagnoses.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.medical_information,
                  ),
                  title: Text(
                    "No diagnoses available",
                  ),
                ),
              )
            else
              Column(
                children: diagnoses.map((document) {
                  final data =
                      document.data()
                          as Map<String, dynamic>;

                  final diagnosis =
                      data['diagnosis']?.toString() ??
                          'Diagnosis unavailable';

                  final doctorName =
                      data['doctorName']?.toString() ??
                          'Doctor';

                  final displayDate =
                      getDisplayDate(data);

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
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

            if (notes.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.note),
                  title: Text(
                    "No nursing notes available",
                  ),
                ),
              )
            else
              Column(
                children: notes.map((document) {
                  final data =
                      document.data()
                          as Map<String, dynamic>;

                  final note =
                      data['note']?.toString() ??
                          'Note unavailable';

                  final nurseName =
                      data['nurseName']?.toString() ??
                          'Nurse';

                  final displayDate =
                      getDisplayDate(data);

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(note),
                      subtitle: Text(
                        "$nurseName • $displayDate",
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  },
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

      final day =
          dateTime.day.toString().padLeft(2, '0');

      final month =
          dateTime.month.toString().padLeft(2, '0');

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