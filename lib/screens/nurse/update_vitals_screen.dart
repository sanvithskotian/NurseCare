import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> saveVitals() async {
  if (temperatureController.text.trim().isEmpty ||
      bloodPressureController.text.trim().isEmpty ||
      heartRateController.text.trim().isEmpty ||
      oxygenLevelController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all vitals"),
      ),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nurse is not logged in"),
      ),
    );
    return;
  }

  final nurseDocument = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!nurseDocument.exists) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nurse profile not found"),
      ),
    );
    return;
  }

  final nurseName =
      nurseDocument.data()?['name']?.toString() ?? 'Unknown Nurse';

  await FirebaseFirestore.instance.collection('vitals').add({
    'patientName': 'John Doe',
    'nurseId': user.uid,
    'nurseName': nurseName,
    'temperature': "${temperatureController.text.trim()} °F",
    'bloodPressure': "${bloodPressureController.text.trim()} mmHg",
    'heartRate': "${heartRateController.text.trim()} BPM",
    'oxygenLevel': "${oxygenLevelController.text.trim()}%",
    'dateTime': _formatDateTime(DateTime.now()),
    'createdAt': FieldValue.serverTimestamp(),
  });

  temperatureController.clear();
  bloodPressureController.clear();
  heartRateController.clear();
  oxygenLevelController.clear();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Vitals updated successfully"),
    ),
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
          _inputField("Temperature, e.g. 98.6", temperatureController),
          const SizedBox(height: 12),
          _inputField("Blood Pressure, e.g. 120/80", bloodPressureController),
          const SizedBox(height: 12),
          _inputField("Heart Rate, e.g. 78", heartRateController),
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