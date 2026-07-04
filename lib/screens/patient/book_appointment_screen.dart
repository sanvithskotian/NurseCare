import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/dummy_data.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  void bookAppointment() {
    if (dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      DummyData.appointments.add(
        Appointment(
          id: "A${DummyData.appointments.length + 1}",
          patientName: DummyData.patient.name,
          doctorName: DummyData.doctor.name.isEmpty ? "Dr. Smith" : DummyData.doctor.name,
          date: "${dateController.text.trim()} - ${timeController.text.trim()}",
          status: "Pending",
        ),
      );
    });

    dateController.clear();
    timeController.clear();

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
    final appointments = DummyData.appointments;

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
          ...appointments.map(
            (appointment) => Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(appointment.doctorName),
                subtitle: Text(appointment.date),
                trailing: Text(appointment.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}