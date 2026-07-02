import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("Dr. Smith"),
              subtitle: Text("10 July 2026 - 10:00 AM"),
              trailing: Chip(label: Text("Confirmed")),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("Dr. Johnson"),
              subtitle: Text("15 July 2026 - 2:00 PM"),
              trailing: Chip(label: Text("Pending")),
            ),
          ),
        ],
      ),
    );
  }
}