import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<int> _getUserCount(String role) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    return snapshot.docs.length;
  }

  Future<int> _getCollectionCount(String collectionName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .get();

    return snapshot.docs.length;
  }

  Future<int> _getAppointmentStatusCount(String status) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('status', isEqualTo: status)
        .get();

    return snapshot.docs.length;
  }

  Future<Map<String, int>> _loadReports() async {
    final results = await Future.wait([
      _getUserCount('patient'),
      _getUserCount('doctor'),
      _getUserCount('nurse'),
      _getCollectionCount('appointments'),
      _getAppointmentStatusCount('Pending'),
      _getAppointmentStatusCount('Approved'),
      _getAppointmentStatusCount('Rejected'),
      _getCollectionCount('diagnoses'),
      _getCollectionCount('prescriptions'),
      _getCollectionCount('nursing_notes'),
    ]);

    return {
      'patients': results[0],
      'doctors': results[1],
      'nurses': results[2],
      'appointments': results[3],
      'pendingAppointments': results[4],
      'approvedAppointments': results[5],
      'rejectedAppointments': results[6],
      'diagnoses': results[7],
      'prescriptions': results[8],
      'nursingNotes': results[9],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Reports"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading reports\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reports = snapshot.data;

          if (reports == null) {
            return const Center(
              child: Text("No report data found."),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [

                const Text(
                  "Real-Time Hospital Statistics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _reportSection(
                  title: "Users",
                  icon: Icons.people,
                  color: Colors.blue,
                  children: [
                    _reportRow("Patients", reports['patients'] ?? 0),
                    _reportRow("Doctors", reports['doctors'] ?? 0),
                    _reportRow("Nurses", reports['nurses'] ?? 0),
                  ],
                ),

                _reportSection(
                  title: "Appointments",
                  icon: Icons.calendar_month,
                  color: Colors.orange,
                  children: [
                    _reportRow("Total", reports['appointments'] ?? 0),
                    _reportRow("Pending", reports['pendingAppointments'] ?? 0),
                    _reportRow("Approved", reports['approvedAppointments'] ?? 0),
                    _reportRow("Rejected", reports['rejectedAppointments'] ?? 0),
                  ],
                ),

                _reportSection(
                  title: "Clinical Records",
                  icon: Icons.medical_information,
                  color: Colors.green,
                  children: [
                    _reportRow("Diagnoses", reports['diagnoses'] ?? 0),
                    _reportRow("Prescriptions", reports['prescriptions'] ?? 0),
                    _reportRow("Nursing Notes", reports['nursingNotes'] ?? 0),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );
  }
    Widget _reportSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}