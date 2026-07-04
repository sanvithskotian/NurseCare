import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends State<DoctorAppointmentsScreen> {

  @override
  Widget build(BuildContext context) {
    final appointments = List.from(DummyData.appointments);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointments"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(appointment.patientName),
                    subtitle: Text(
                      "Doctor: ${appointment.doctorName}\nDate: ${appointment.date}",
                    ),
                    trailing: Text(
                      appointment.status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (appointment.status == "Pending")
                    Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            appointment.status = "Approved";
          });
        },
        child: const Text("Approve"),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            appointment.status = "Rejected";
          });
        },
        child: const Text("Reject"),
      ),
    ),
  ],
),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}