import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String? selectedDoctorId;
  String? selectedDoctorName;

  Future<void> bookAppointment() async {
    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a doctor"),
        ),
      );
      return;
    }

    if (dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final patientName =
        userDoc.data()?['name'] ?? 'Unknown Patient';

    await FirebaseFirestore.instance
        .collection('appointments')
        .add({
      'patientId': user.uid,
      'patientName': patientName,
      'patientEmail': user.email,

      'doctorId': selectedDoctorId,
      'doctorName': selectedDoctorName,

      'date': dateController.text.trim(),
      'time': timeController.text.trim(),

      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    dateController.clear();
    timeController.clear();

    setState(() {
      selectedDoctorId = null;
      selectedDoctorName = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment booked successfully"),
      ),
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

          /// Doctor Dropdown
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'doctor')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Text(
                  "No doctors available",
                );
              }

              return DropdownButtonFormField<String>(
                value: selectedDoctorId,
                decoration: const InputDecoration(
                  labelText: "Select Doctor",
                  border: OutlineInputBorder(),
                ),
                items: snapshot.data!.docs.map((doc) {
                  final doctor =
                      doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(
                      doctor['name'] ?? 'Doctor',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDoctorId = value;

                    final selectedDoctor = snapshot
                        .data!.docs
                        .firstWhere(
                          (doc) => doc.id == value,
                        );

                    selectedDoctorName =
                        (selectedDoctor.data()
                            as Map<String, dynamic>)['name'];
                  });
                },
              );
            },
          ),

          const SizedBox(height: 12),

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

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: bookAppointment,
            child: const Text(
              "Book Appointment",
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "My Appointments",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where(
                  'patientId',
                  isEqualTo: user?.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  "Something went wrong",
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final appointments =
                  snapshot.data!.docs;

              if (appointments.isEmpty) {
                return const Text(
                  "No appointments booked yet",
                );
              }

              return Column(
                children:
                    appointments.map((doc) {
                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      title: Text(
                        data['doctorName'] ??
                            'Doctor',
                      ),
                      subtitle: Text(
                        "${data['date']} - ${data['time']}",
                      ),
                      trailing: Text(
                        data['status'] ??
                            'Pending',
                      ),
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