import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_patient_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

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
        title: const Text("My Patients"),
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'patient')
      .where(
      'assignedDoctorId',
      isEqualTo: doctor.uid,
    )
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Text("Something went wrong"),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
  child: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.people_outline,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          "No Assigned Patients",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Patients assigned to you will appear here after you approve their appointments.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      ],
    ),
  ),
);
    }

    final patients = snapshot.data!.docs;

    if (patients.isEmpty) {
      return const Center(
        child: Text("No patients found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient =
            patients[index].data() as Map<String, dynamic>;

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(patient['name'] ?? 'Unknown'),
            subtitle: Text(patient['email'] ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorPatientDetailsScreen(
                    patientId: patients[index].id,
                    patientName: patient['name']?.toString() ?? 'Unknown Patient',
                  ),
                ),
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