import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/dummy_data.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  Future<void> bookAppointment() async {
    if (dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }
    final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

final patientName = userDoc.data()?['name'] ?? 'Unknown Patient';
    await FirebaseFirestore.instance.collection('appointments').add({
      'patientId': user.uid,
      'patientName': patientName,
      'patientEmail': user.email,
      'doctorName': DummyData.doctor.name.isEmpty
          ? "Dr. Smith"
          : DummyData.doctor.name,
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    dateController.clear();
    timeController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment booked successfully")),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: "Date",
              hintText: "Example: 20 July 2026",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: "Time",
              hintText: "Example: 10:30 AM",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: bookAppointment,
            child: const Text("Book Appointment"),
          ),
          const SizedBox(height: 20),
          const Text(
            "My Appointments",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final appointments = snapshot.data!.docs;

              if (appointments.isEmpty) {
                return const Text("No appointments booked yet");
              }

              return Column(
                children: appointments.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(data['doctorName'] ?? 'Doctor'),
                      subtitle: Text(
                        "${data['date'] ?? ''} - ${data['time'] ?? ''}",
                      ),
                      trailing: Text(data['status'] ?? 'Pending'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}