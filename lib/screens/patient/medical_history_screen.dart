import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("General Checkup"),
              subtitle: Text("January 2026"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("Fever Treatment"),
              subtitle: Text("March 2026"),
            ),
          ),
        ],
      ),
    );
  }
}