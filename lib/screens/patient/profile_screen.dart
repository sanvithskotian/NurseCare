import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        title: const Text("Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Profile not found"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final String role =
              (data['role'] ?? '').toString();

          final String formattedRole =
              role.isNotEmpty
                  ? role[0].toUpperCase() +
                      role.substring(1)
                  : '';

          final String initial =
              (data['name'] ?? 'U')
                  .toString()
                  .substring(0, 1)
                  .toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      data['name'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Name"),
                      subtitle: Text(
                        data['name'] ?? '',
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(
                        data['email'] ?? '',
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(
                        Icons.admin_panel_settings,
                      ),
                      title: const Text("Role"),
                      subtitle: Text(formattedRole),
                    ),

                    if (data.containsKey('specialization')) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.local_hospital,
                        ),
                        title: const Text(
                          "Specialization",
                        ),
                        subtitle: Text(
                          data['specialization'],
                        ),
                      ),
                    ],

                    if (data.containsKey('department')) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.apartment,
                        ),
                        title: const Text(
                          "Department",
                        ),
                        subtitle: Text(
                          data['department'],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}