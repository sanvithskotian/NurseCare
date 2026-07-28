import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'nurse_patient_details_screen.dart';

class NursePatientsScreen extends StatefulWidget {
  const NursePatientsScreen({super.key});

  @override
  State<NursePatientsScreen> createState() =>
      _NursePatientsScreenState();
}

class _NursePatientsScreenState
    extends State<NursePatientsScreen> {
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
    final currentNurse = FirebaseAuth.instance.currentUser;

    if (currentNurse == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in again."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
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
                    "Search patient by name or email...",
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
                  .where(
                    'role',
                    isEqualTo: 'patient',
                  )
                  .where(
                    'assignedNurseIds',
                    arrayContains: currentNurse.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Text(
                        "Something went wrong.\n\n"
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allPatients =
                    snapshot.data?.docs ?? [];

                if (allPatients.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.personal_injury_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No patients assigned",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Patients assigned to you by management will appear here.",
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final query =
                    _searchQuery.trim().toLowerCase();

                final patients =
                    allPatients.where((document) {
                  final patient =
                      document.data()
                          as Map<String, dynamic>;

                  final name =
                      patient['name']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  final email =
                      patient['email']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  return name.contains(query) ||
                      email.contains(query);
                }).toList();

                if (patients.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching patients found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patientDocument =
                        patients[index];

                    final patient =
                        patientDocument.data()
                            as Map<String, dynamic>;

                    final patientId =
                        patientDocument.id;

                    final patientName =
                        patient['name']?.toString() ??
                            'Unknown Patient';

                    final patientEmail =
                        patient['email']?.toString() ??
                            'No email available';

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(patientEmail),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NursePatientDetailsScreen(
                                patientId: patientId,
                                patientName:
                                    patientName,
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
          ),
        ],
      ),
    );
  }
}