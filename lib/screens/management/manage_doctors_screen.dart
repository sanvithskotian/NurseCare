import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() =>
      _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState
    extends State<ManageDoctorsScreen> {

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Doctors"),
      ),
      body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              "Search doctor, email or specialization...",
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
            borderRadius:
                BorderRadius.circular(12),
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

          final allDoctors =
    snapshot.data?.docs ?? [];

final doctors = allDoctors.where((document) {
  final doctor =
      document.data() as Map<String, dynamic>;

  final name =
      doctor['name']
              ?.toString()
              .toLowerCase() ??
          '';

  final email =
      doctor['email']
              ?.toString()
              .toLowerCase() ??
          '';

  final specialization =
      doctor['specialization']
              ?.toString()
              .toLowerCase() ??
          '';

  final query =
      _searchQuery.trim().toLowerCase();

  return name.contains(query) ||
      email.contains(query) ||
      specialization.contains(query);
}).toList();

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
    ),
  ],
      ),
    );
  }
}