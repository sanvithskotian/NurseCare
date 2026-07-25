import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageDoctorsScreen extends StatelessWidget {
  const ManageDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Doctors"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final doctors = snapshot.data!.docs;

          if (doctors.isEmpty) {
            return const Center(
              child: Text(
                "No doctors found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor =
                  doctors[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    doctor['name'] ?? 'Unknown',
                  ),
                  subtitle: Text(
                    "Specialization: ${doctor['specialization'] ?? 'Not Available'}",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}