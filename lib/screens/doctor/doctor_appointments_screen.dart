import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = DummyData.appointments;

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
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(appointment.patientName),
              subtitle: Text(
                "${appointment.doctorName}\n${appointment.date}",
              ),
              trailing: Text(appointment.status),
            ),
          );
        },
      ),
    );
  }
}