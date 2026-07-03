import 'package:flutter/material.dart';
import '../../models/vital.dart';
import '../../services/dummy_data.dart';

class UpdateVitalsScreen extends StatefulWidget {
  const UpdateVitalsScreen({super.key});

  @override
  State<UpdateVitalsScreen> createState() => _UpdateVitalsScreenState();
}

class _UpdateVitalsScreenState extends State<UpdateVitalsScreen> {
  final temperatureController = TextEditingController();
  final bloodPressureController = TextEditingController();
  final heartRateController = TextEditingController();
  final oxygenLevelController = TextEditingController();

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
  
    final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour == 0
          ? 12
          : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";

    return "$day/$month/$year, $hour:$minute $period";
  }

  void saveVitals() {
    if (temperatureController.text.trim().isEmpty ||
        bloodPressureController.text.trim().isEmpty ||
        heartRateController.text.trim().isEmpty ||
        oxygenLevelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all vitals")),
      );
      return;
    }

    setState(() {
      DummyData.vitals.insert(
        0,
        Vital(
          id: "V${DummyData.vitals.length + 1}",
          patientName: DummyData.patient.name,
          temperature: "${temperatureController.text.trim()} °F",
          bloodPressure: "${bloodPressureController.text.trim()} mmHg",
          heartRate: "${heartRateController.text.trim()} BPM",
          oxygenLevel: "${oxygenLevelController.text.trim()}%",
          dateTime: _formatDateTime(DateTime.now()),
        ),
      );
    });

    temperatureController.clear();
    bloodPressureController.clear();
    heartRateController.clear();
    oxygenLevelController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vitals updated successfully")),
    );
  }

  @override
  void dispose() {
    temperatureController.dispose();
    bloodPressureController.dispose();
    heartRateController.dispose();
    oxygenLevelController.dispose();
    super.dispose();
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Vitals"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _inputField("Temperature, e.g. 98.6 ", temperatureController),
          const SizedBox(height: 12),
          _inputField("Blood Pressure, e.g. 120/80", bloodPressureController),
          const SizedBox(height: 12),
          _inputField("Heart Rate, e.g. 78 ", heartRateController),
          const SizedBox(height: 12),
          _inputField("Oxygen Level, e.g. 98", oxygenLevelController),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: saveVitals,
            child: const Text("Save Vitals"),
          ),
        ],
      ),
    );
  }
}