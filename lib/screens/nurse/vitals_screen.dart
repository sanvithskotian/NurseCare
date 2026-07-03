import 'package:flutter/material.dart';

class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Vitals"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Heart Rate"),
              subtitle: Text("78 BPM"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.thermostat),
              title: Text("Temperature"),
              subtitle: Text("98.6 °F"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.monitor_heart),
              title: Text("Blood Pressure"),
              subtitle: Text("120 / 80"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.air),
              title: Text("Oxygen Level"),
              subtitle: Text("98%"),
            ),
          ),
        ],
      ),
    );
  }
}