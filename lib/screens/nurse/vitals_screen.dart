import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vitals = DummyData.vitals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vitals History"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vitals.length,
        itemBuilder: (context, index) {
          final vital = vitals[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.monitor_heart, color: Colors.teal),
              title: Text(vital.dateTime),
              subtitle: Text(
                "Temp: ${vital.temperature}\n"
                "BP: ${vital.bloodPressure}\n"
                "Heart Rate: ${vital.heartRate}\n"
                "Oxygen: ${vital.oxygenLevel}",
              ),
            ),
          );
        },
      ),
    );
  }
}