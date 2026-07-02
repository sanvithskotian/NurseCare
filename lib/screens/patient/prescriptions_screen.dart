import 'package:flutter/material.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescriptions"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.medication),
              title: Text("Paracetamol"),
              subtitle: Text("500mg - Twice Daily"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.medication),
              title: Text("Vitamin D"),
              subtitle: Text("Once Daily"),
            ),
          ),
        ],
      ),
    );
  }
}