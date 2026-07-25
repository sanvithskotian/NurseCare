import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';
import 'medical_history_screen.dart';
import 'prescriptions_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../role_selection/role_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    

    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
  title: const Text("Patient Dashboard"),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Logout"),
      content: const Text(
        "Are you sure you want to logout?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),
          FilledButton(

    style: FilledButton.styleFrom(

      backgroundColor: Colors.red,

      foregroundColor: Colors.white,

    ),
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );
  if (shouldLogout != true) return;
        await FirebaseAuth.instance.signOut();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const RoleSelectionScreen(),
          ),
          (route) => false,
        );
      },
    ),
  ],
),
      body: FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
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
        child: Text("Patient profile not found"),
      );
    }

    final patient =
        snapshot.data!.data() as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${patient['name']}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Email: ${patient['email']}",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildCard(
              context,
              "Appointments",
              Icons.calendar_month,
              const BookAppointmentScreen(),
            ),
            _buildCard(
              context,
              "Prescriptions",
              Icons.medication,
              const PrescriptionsScreen(),
            ),
            _buildCard(
              context,
              "Medical History",
              Icons.history,
              const MedicalHistoryScreen(),
            ),
            _buildCard(
              context,
              "Profile",
              Icons.person,
              const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  },
),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.teal),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}