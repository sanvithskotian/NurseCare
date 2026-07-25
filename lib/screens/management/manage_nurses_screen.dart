import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageNursesScreen extends StatelessWidget {
  const ManageNursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Nurses"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'nurse')
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

          final nurses = snapshot.data!.docs;

          if (nurses.isEmpty) {
            return const Center(
              child: Text(
                "No nurses found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nurses.length,
            itemBuilder: (context, index) {
              final nurse =
                  nurses[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.medical_services,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    nurse['name'] ?? 'Unknown',
                  ),
                  subtitle: Text(
                    "Department: ${nurse['department'] ?? 'Not Available'}",
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