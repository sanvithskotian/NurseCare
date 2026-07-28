import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  final dateController = TextEditingController();
  String? selectedTime;

  Future<void> _selectDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    dateController.text =
        DateFormat('dd MMM yyyy').format(picked);
  }
}
List<String> getTimeSlots() {
  List<String> slots = [];

  DateTime start = DateTime(2026, 1, 1, 9, 0);
  DateTime end = DateTime(2026, 1, 1, 17, 0);

  while (!start.isAfter(end)) {
    slots.add(DateFormat('hh:mm a').format(start));
    start = start.add(const Duration(minutes: 30));
  }

  return slots;
}


  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedDoctorSpecialization;

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
    selectedTime == null) {
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

// Check if the selected doctor already has an appointment
// at the selected date and time.
final existingAppointment = await FirebaseFirestore.instance
    .collection('appointments')
    .where('doctorId', isEqualTo: selectedDoctorId)
    .where('date', isEqualTo: dateController.text.trim())
    .where('time', isEqualTo: selectedTime)
    .where(
      'status',
      whereIn: ['Pending', 'Approved'],
    )
    .limit(1)
    .get();

if (existingAppointment.docs.isNotEmpty) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "This time slot is already booked. Please choose another time.",
      ),
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
      'doctorSpecialization': selectedDoctorSpecialization,

      'date': dateController.text.trim(),
      'time': selectedTime,

      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    dateController.clear();
    

    setState(() {
      selectedDoctorId = null;
      selectedDoctorName = null;
      selectedDoctorSpecialization = null;
      selectedTime = null;
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
                isExpanded: true,
                itemHeight: 60,
                decoration: const InputDecoration(
                  labelText: "Select Doctor",
                  border: OutlineInputBorder(),
                ),
                items: snapshot.data!.docs.map((doc) {
                  final doctor =
                      doc.data() as Map<String, dynamic>;

                  return DropdownMenuItem<String>(
  value: doc.id,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        doctor['name'] ?? 'Doctor',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        doctor['specialization'] ?? 'General',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  ),
);
                }).toList(),
                selectedItemBuilder: (context) {
  return snapshot.data!.docs.map((doc) {
    final doctor = doc.data() as Map<String, dynamic>;

    return Text(
      doctor['name'] ?? 'Doctor',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }).toList();
},
                onChanged: (value) {
                  setState(() {
                    selectedDoctorId = value;

                    final selectedDoctor = snapshot
                        .data!.docs
                        .firstWhere(
                          (doc) => doc.id == value,
                        );

                    final doctorData =
    selectedDoctor.data() as Map<String, dynamic>;

selectedDoctorName = doctorData['name'];
selectedDoctorSpecialization =
    doctorData['specialization'];
                  });
                },
              );
            },
          ),

          const SizedBox(height: 12),

          TextField(
  controller: dateController,
  readOnly: true,
  onTap: _selectDate,
  decoration: const InputDecoration(
    labelText: "Date",
    hintText: "Select appointment date",
    prefixIcon: Icon(Icons.calendar_today),
    border: OutlineInputBorder(),
  ),
),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
  value: selectedTime,
  decoration: const InputDecoration(
    labelText: "Select Time",
    prefixIcon: Icon(Icons.access_time),
    border: OutlineInputBorder(),
  ),
  items: getTimeSlots().map((time) {
    return DropdownMenuItem(
      value: time,
      child: Text(time),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedTime = value;
    });
  },
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