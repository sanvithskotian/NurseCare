import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';
import 'doctor_prescription_screen.dart';
import 'doctor_appointments_screen.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(patient.name),
                subtitle: Text(
                  "ID: ${patient.id} | Age: ${patient.age}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildCard(
                    context,
                    "Patients",
                    Icons.people,
                    null,
                  ),
                  _buildCard(
                    context,
                    "Diagnosis",
                    Icons.medical_information,
                    null,
                  ),
                  _buildCard(
                    context,
                    "Prescription",
                    Icons.medication,
                    const DoctorPrescriptionScreen(),
                  ),
                  _buildCard(
                    context,
                    "Appointments",
                    Icons.calendar_month,
                    const DoctorAppointmentsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget? screen,
  ) {
    return Card(
      child: InkWell(
        onTap: screen == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => screen,
                  ),
                );
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}