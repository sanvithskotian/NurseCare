import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageNursesScreen extends StatefulWidget {
  const ManageNursesScreen({super.key});

  @override
  State<ManageNursesScreen> createState() =>
      _ManageNursesScreenState();
}

class _ManageNursesScreenState
    extends State<ManageNursesScreen> {
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
        title: const Text("Manage Nurses"),
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
                    "Search nurse, email or department...",
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
                  .where('role', isEqualTo: 'nurse')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong."),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allNurses =
                    snapshot.data?.docs ?? [];

                final query =
                    _searchQuery.trim().toLowerCase();

                final nurses =
                    allNurses.where((document) {
                  final nurse =
                      document.data()
                          as Map<String, dynamic>;

                  final name =
                      nurse['name']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  final email =
                      nurse['email']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  final department =
                      nurse['department']
                              ?.toString()
                              .toLowerCase() ??
                          '';

                  return name.contains(query) ||
                      email.contains(query) ||
                      department.contains(query);
                }).toList();

                if (allNurses.isEmpty) {
                  return const Center(
                    child: Text(
                      "No nurses found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                if (nurses.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching nurses found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: nurses.length,
                  itemBuilder: (context, index) {
                    final nurse =
                        nurses[index].data()
                            as Map<String, dynamic>;

                    final nurseName =
                        nurse['name']?.toString() ??
                            'Unknown';

                    final nurseEmail =
                        nurse['email']?.toString() ??
                            'No email available';

                    final department =
                        nurse['department']?.toString() ??
                            'Not Available';

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(nurseName),
                        subtitle: Text(
                          "$nurseEmail\n"
                          "Department: $department",
                        ),
                        isThreeLine: true,
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