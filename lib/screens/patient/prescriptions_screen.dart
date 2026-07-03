import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prescriptions = DummyData.prescriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.medication),
              title: Text(prescription.medicine),
              subtitle: Text(
                "${prescription.dosage}\nDuration: ${prescription.duration}",
              ),
              trailing: Text(prescription.doctorName),
            ),
          );
        },
      ),
    );
  }
}